--region *.lua
--Date
--region *.lua
--Date

if not testCommon then
    os.loadAPI("test/testCommon")
end

testCommon.reloadAPI("turtle", "test/mocks/turtle")
testCommon.reloadAPI("terp", "test/mocks/turtle")

function testCreate()
    local target = terp.create()
    assert(target, "Expected a non-nil object")
    return true
end

function testTurnAround()
    assert(false, "TODO")
end

function testDetectRight()
    assert(false, "TODO")
end

function testDetectLeft()
    assert(false, "TODO")
end

function testDetectBack()
    assert(false, "TODO")
end

function testBack()
    assert(false, "TODO")
end

function testUp()
    assert(false, "TODO")
end

function testDown()
    assert(false, "TODO")
end

function testRight(distance)
    assert(false, "TODO")
end

function testLeft(distance)
    assert(false, "TODO")
end



--endregion
