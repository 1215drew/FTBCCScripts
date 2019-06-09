-- Constants
local MonitorSide = "left"
local Capacitance = 1.6 -- capacitance in uF

function StageVoltageToJoules(voltage)
  return (0.5 * Capacitance * ((voltage/1000) ^ 2))
end

function SignalToVoltage(signalA, signalB)
  return (( 250 / 255 * ((16 * signalA) + signalB)) * 1000)
end

function SafeDistancePhysical(joules)
  return math.sqrt( joules / 50000)
end

function SafeDistanceAudible(joules)
  return (math.sqrt(joules) / 50)
end

function IsValueCloser(targetVal, currentVal, testVal)
  local distanceCurrent = math.abs(targetVal - currentVal)
  local distanceTest = math.abs(targetVal - testVal)
  if distanceTest < distanceCurrent then
    return true
  end
  
  return false
end

function SolveForJoules(targetJoules, numStages)
  local closestA = -1
  local closestB = -1
  local closestJoules = -1
  
  for i = 0, 15, 1
  do
    for j = 0, 15, 1
    do
      local tempVolts = SignalToVoltage(i, j)
      local tempJoules = StageVoltageToJoules(tempVolts) * numStages
      if closestJoules == -1 or IsValueCloser(targetJoules, closestJoules, tempJoules) then
        closestJoules = tempJoules
        closestA = i
        closestB = j
      end
    end
  end
  
  return closestA, closestB, closestJoules
end

function GetUserInput(name)
  print("Enter value for "..name)
  return read()
end

function MonitorNewline(mon)
  local _,cY = mon.getCursorPos()
  mon.setCursorPos(1, cY+1)
end

function signaltostring(signal)
  if signal >= 0 and signal <= 9 then
    return tostring(signal)
  elseif signal == 10 then
    return "A"
  elseif signal == 11 then
    return "B"
  elseif signal == 12 then
    return "C"
  elseif signal == 13 then
    return "D"
  elseif signal == 14 then
    return "E"
  elseif signal == 15 then
    return "F"
  else
    return -1
  end
end

function stringtosignal(signal)
  if signal == "a" or signal == "A" then
    return 10
  elseif signal == "b" or signal == "B" then
    return 11
  elseif signal == "c" or signal == "C" then
    return 12
  elseif signal == "d" or signal == "D" then
    return 13
  elseif signal == "e" or signal == "E" then
    return 14
  elseif signal == "f" or signal == "F" then
    return 15
  else
    return tonumber(signal)
  end
end

-- Main Program
local displayNumStages = 0
local displayA = -1
local displayB = -1
local displayTargetJoules = 0
local displayClosestJoules = 0
local displayStageVoltage = 0
local displayMaxTotalVoltage = 0
local displayMinTotalVoltage = 0

local monitor = peripheral.wrap(MonitorSide)

function RefreshMonitor()
  monitor.clear()
  monitor.setCursorPos(1,1)
  monitor.write("Marx Generator Firing Computer")
  MonitorNewline(monitor)
  monitor.write("Num Stages: "..tostring(displayNumStages))
  MonitorNewline(monitor)
  monitor.write("Signal A: "..signaltostring(displayA))
  MonitorNewline(monitor)
  monitor.write("Signal B: "..signaltostring(displayB))
  MonitorNewline(monitor)
  monitor.write("Target Joules: "..tostring(math.floor(displayTargetJoules / 100) / 10))
  MonitorNewline(monitor)
  monitor.write("Closest Joules: "..tostring(math.floor(displayClosestJoules / 100) / 10))
  MonitorNewline(monitor)
  monitor.write("Per Stage Voltage: "..tostring(math.floor(displayStageVoltage / 100) / 10))
  MonitorNewline(monitor)
  monitor.write("Total Voltage: "..tostring(math.floor(displayStageVoltage * displayNumStages / 100) / 10))
  MonitorNewline(monitor)
  monitor.write("Max Total Voltage: "..tostring(math.floor(displayMaxTotalVoltage / 100) / 10))
  MonitorNewline(monitor)
  monitor.write("Min Total Voltage: "..tostring(math.floor(displayMinTotalVoltage / 100 ) / 10))
  MonitorNewline(monitor)
end

while true do
  term.clear()
  term.setCursorPos(1,1)
  
  print("Marx Generator Firing Computer")
  
  RefreshMonitor()
  
  print("Main Menu")
  print(" 1) Set Number of Capacitor Stages")
  print(" 2) Solve for Target Joules")
  print(" 3) Solve for Signal A and B")
  print(" 4) Reset all Values")
  print()
  print("Enter Selection:")
  local selection = read()
  
  if selection == "1" then
    displayNumStages = tonumber(GetUserInput("Capacitor Stages"))
    displayMaxTotalVoltage = (250000 * displayNumStages)
    displayMinTotalVoltage = math.max((displayMaxTotalVoltage * 0.3), 125000)
  elseif selection == "2" then
    displayTargetJoules = tonumber(GetUserInput("Target Joules"))
    print("Calculating Closest Joules, this may take a moment.")
    displayA, displayB, displayClosestJoules = SolveForJoules(displayTargetJoules, displayNumStages)
    displayStageVoltage = SignalToVoltage(displayA, displayB)
    print("Done!")
  elseif selection == "3" then
    displayA = stringtosignal(GetUserInput("Signal A"))
    displayB = stringtosignal(GetUserInput("Signal B"))
    displayStageVoltage = SignalToVoltage(displayA, displayB)
    displayTargetJoules = StageVoltageToJoules(displayStageVoltage) * displayNumStages
    displayClosestJoules = displayTargetJoules
  elseif selection == "4" then
    displayNumStages = 0
    displayA = -1
    displayB = -1
    displayTargetJoules = 0
    displayClosestJoules = 0
    displayStageVoltage = 0
    displayMaxTotalVoltage = 0
    displayMinTotalVoltage = 0
  else
    print("Invalid Menu Option")
  end
  RefreshMonitor()
  sleep(1)
end
