local M = {}

M.fib = function(n)
  local a = 1
  local b = 1
  if n < 2 then
    return n
  end
  for _ = 2, n do
    b, a = a + b, b
  end
  return a
end

return M
