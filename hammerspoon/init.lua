-- Global Mic Mute Toggle (F6)
-- Toggles system input device mute, works across all apps.

local micMenubar = hs.menubar.new()
local savedVolumes = {}
local micMuted = false

local function getInputDevices()
    local devices = {}
    for _, dev in ipairs(hs.audiodevice.allInputDevices()) do
        table.insert(devices, dev)
    end
    return devices
end

local function updateMicStatus()
    if micMuted then
        micMenubar:setTitle("🔇")
        micMenubar:setTooltip("Microphone is MUTED (F6 to toggle)")
    else
        micMenubar:setTitle("🎤")
        micMenubar:setTooltip("Microphone is LIVE (F6 to toggle)")
    end
end

local function toggleMicMute()
    local devices = getInputDevices()
    if #devices == 0 then
        hs.alert.show("No input device found")
        return
    end
    if micMuted then
        -- Unmute all input devices
        for _, dev in ipairs(devices) do
            local uid = dev:uid()
            local vol = savedVolumes[uid] or 100
            dev:setInputMuted(false)
            dev:setInputVolume(vol)
        end
        savedVolumes = {}
        micMuted = false
        hs.alert.show("🎤 Mic ON", nil, 0.75)
    else
        -- Mute all input devices
        savedVolumes = {}
        for _, dev in ipairs(devices) do
            local uid = dev:uid()
            local vol = dev:inputVolume()
            savedVolumes[uid] = (vol and vol > 0) and vol or 100
            dev:setInputVolume(0)
            dev:setInputMuted(true)
        end
        micMuted = true
        hs.alert.show("🔇 Mic MUTED", nil, 0.75)
    end
    updateMicStatus()
end

-- Bind F6 to toggle mic mute
hs.hotkey.bind({}, "f6", toggleMicMute)

-- Clicking the menubar icon also toggles
micMenubar:setClickCallback(toggleMicMute)

-- Watch for audio device changes (e.g. plugging in a USB mic)
hs.audiodevice.watcher.setCallback(function(event)
    updateMicStatus()
end)
hs.audiodevice.watcher.start()

-- Initialize menubar indicator
updateMicStatus()

--------------------------------------------------------------------------------
-- System Monitor (CPU, Memory, Network) — menubar widget, updates every 3s
--------------------------------------------------------------------------------

local sysMenubar = hs.menubar.new()
local prevBytesIn, prevBytesOut = 0, 0
local prevTime = hs.timer.absoluteTime()

local function formatBytes(bytes)
    bytes = math.floor(bytes)
    if bytes >= 1048576 then
        return string.format("%.1fM", bytes / 1048576)
    elseif bytes >= 1024 then
        return string.format("%.0fK", bytes / 1024)
    else
        return string.format("%dB", math.floor(bytes))
    end
end

local function getNetworkBytes()
    local output, status = hs.execute("netstat -ibn | awk '/en0.*Link/ {print $7, $10; exit}'")
    if not status or not output then return 0, 0 end
    local bytesIn, bytesOut = output:match("(%d+)%s+(%d+)")
    return tonumber(bytesIn) or 0, tonumber(bytesOut) or 0
end

local function getCpuPercent()
    local usage = hs.host.cpuUsage()
    if not usage then return 0 end
    return math.floor(usage.overall.active + 0.5)
end

local function getMemPercent()
    local cmd = "vm_stat | awk -v total=$(sysctl -n hw.memsize) -v ps=$(sysctl -n vm.pagesize) "
        .. "'/Pages active|Pages wired down|Pages occupied by compressor/ "
        .. "{gsub(/\\\\./, \"\", $NF); sum += $NF} "
        .. "END {printf \"%d\", (sum * ps / total) * 100}'"
    local output = hs.execute(cmd)
    return tonumber(output) or 0
end

local function updateSysMonitor()
    local cpu = getCpuPercent()
    local mem = getMemPercent()

    local now = hs.timer.absoluteTime()
    local elapsed = (now - prevTime) / 1e9 -- seconds
    local bytesIn, bytesOut = getNetworkBytes()

    local rateIn, rateOut = 0, 0
    if elapsed > 0 and prevBytesIn > 0 then
        rateIn = math.max(0, (bytesIn - prevBytesIn) / elapsed)
        rateOut = math.max(0, (bytesOut - prevBytesOut) / elapsed)
    end

    prevBytesIn, prevBytesOut = bytesIn, bytesOut
    prevTime = now

    local title = string.format("CPU %d%%  MEM %d%%  ↓%s/s ↑%s/s",
        cpu, mem, formatBytes(rateIn), formatBytes(rateOut))

    sysMenubar:setTitle(title)
    sysMenubar:setTooltip("Click to open Activity Monitor")
end

sysMenubar:setClickCallback(function()
    hs.application.launchOrFocus("Activity Monitor")
end)

-- Initial read to seed the network counters
prevBytesIn, prevBytesOut = getNetworkBytes()
prevTime = hs.timer.absoluteTime()

-- Update every 3 seconds
local sysTimer = hs.timer.doEvery(3, updateSysMonitor)
updateSysMonitor()
