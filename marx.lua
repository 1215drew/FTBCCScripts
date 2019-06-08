-- Constants
local MonitorSide = "left"
local Capacitance = 1.6 -- capacitance in uF

function VoltageToJoules(voltage)
  return (0.5 * Capacitance * (voltage ^ 2))
end

function SignalToVoltage(signalA, signalB)
  return ( 250 / 255 * ((16 * signalA) + signalB))
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

function SolveForJoules(targetJoules)
  local closestA = -1
  local closestB = -1
  local closestJoules = -1
  
  for i = 0, 15, 1
  do
    for j = 0, 15, 1
    do
      local tempVolts = SignalToVoltage(i, j)
      local tempJoules = VoltageToJoules(tempVolts)
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

-- Main Program
local displayNumStages = -1
local displayA = -1
local displayB = -1
local displayTargetJoules = -1
local displayClosestJoules = -1
local displayVoltage = -1
local displayMaxVoltage = -1
local displayMinVoltage = -1

local monitor = peripheral.wrap(MonitorSide)

while true do
  print("Marx Generator Firing Computer")
  
  monitor.write("Marx Generator Firing Computer\n")
  monitor.write("Num Stages: "..tostring(displayNumStages).."\n")
  monitor.write("Signal A: "..tostring(displayA).."\n")
  monitor.write("Signal B: "..tostring(displayB).."\n")
  monitor.write("Target Joules: "..tostring(displayTargetJoules).."\n")
  monitor.write("Closest Joules: "..tostring(displayClosestJoules).."\n")
  monitor.write("Voltage: "..tostring(displayVoltage).."\n")
  monitor.write("Max Voltage: "..tostring(displayMaxVoltage).."\n")
  monitor.write("Min Voltage: "..tostring(displayMinVoltage).."\n")
  
  print("Main Menu")
  print(" 1) Set Number of Capacitor Stages")
  print(" 2) Solve for Target Joules")
  print(" 3) Solve for Signal A and B")
  print(" 4) Reset all Values")
  print()
  print("Enter Selection:")
  local selection = read()
  
  if selection == 1 then
    displayNumStages = GetUserInput("Capacitor Stages")
    displayMaxVoltage = (250000 * displayNumStages)
    displayMinVoltage = math.Max((displayMaxVoltage * 0.3), 125000)
  elseif selection == 1 then
    displayTargetJoules = GetUserInput("Target Joules")
    print("Calculating Closest Joules, this may take a moment.")
    displayA, displayB, displayClosestJoules = SolveForJoules(displayTargetJoules)
    displayVoltage = SignalToVoltage(displayA, displayB)
    print("Done!")
  elseif selection == 3 then
    displayA = GetUserInput("Signal A")
    displayB = GetUserInput("Signal B")
    displayVoltage = SignalToVoltage(displayA, displayB)
    displayTargetJoules = VoltageToJoules(displayVoltage)
    displayClosestJoules = displayTargetJoules
  elseif selection == 4 then
    displayNumStages = -1
    displayA = -1
    displayB = -1
    displayTargetJoules = -1
    displayClosestJoules = -1
    displayVoltage = -1
    displayMaxVoltage = -1
    displayMinVoltage = -1
  else
    print("Invalid Menu Option")
  end
  
  sleep(3)
  
  monitor.clear()
  term.clear()
  term.setCursorPos(1,1)
end
