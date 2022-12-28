return function(elapsed)
  local seconds = elapsed % 60
  local minutes = math.floor(elapsed / 60)
  if minutes < 60 then
    return ("%d:%02d"):format(minutes, seconds)
  end

  local hours = math.floor(minutes / 60)
  return ("%d:%02d:02d"):format(hours, minutes, seconds)
end
