local b
local a = " return { foo = 1 }"
local bar = false
function c() 
	if bar then return nil end
	bar = true
	return a
end
test
test
test

b = load(c)()
print(b.foo)


	