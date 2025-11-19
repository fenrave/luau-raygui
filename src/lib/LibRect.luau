--[==[+

This is a helper library meant to make the process of interacting with rectangles just a bit easier (no raw buffer reads/writes)

+]==]--

local raygui = require("@raygui")

local Rectangle = raygui.components.structs.Rectangle

type List<k, t> = {
    [k]: t
}

type RectLib = {
    new: (
        self: RectLib,
        Name: string | number,
        Position: vector,
        Size: vector
    ) -> Rectangle
}

type InternalRect = {
    read rect: raygui.Rectangle,
    read Name: string,
    x: number,
    y: number,
    width: number,
    height: number
}

export type Rectangle = typeof(setmetatable(
        {} :: InternalRect,
        {} :: {
            read __index: (t: InternalRect, Index: string) -> number,
            read __newindex: (t: InternalRect, Index: string, Value: number) -> ()
        }
    )
)

local LibRect = {} :: RectLib
local RectTracker: List<string | number, raygui.Rectangle> = {}

local rOffsets: List<string, number> = {
    x = 0,
    y = 4,
    width = 8,
    height = 12
}

local Indexer: Indexer = {
    __index = function(t: InternalRect, Index: string): number
        return buffer.readf32(t.rect, rOffsets[Index])
    end,

    __newindex = function(t: InternalRect, Index: string, Value: number): ()
        buffer.writef32(t.rect, rOffsets[Index], Value)
		rawset(t :: any, Index, nil)
    end
}

type Indexer = {
    __index: (t: InternalRect, Index: string) -> number,
    __newindex: (t: InternalRect, Index: string, Value: number) -> ()
}


function LibRect:new(Name: string | number, Position: vector, Size: vector): Rectangle

    local NewRect: raygui.Rectangle = Rectangle:new{
        x = Position.x,
        y = Position.y,
        width = Size.x,
        height = Size.y
    }

    local NewIndexer: Indexer = table.clone(Indexer)

    local Rect = setmetatable(
        {
            rect = NewRect,
            Name = Name
        }, 
        NewIndexer
    ) :: Rectangle


    RectTracker[Name] = Rect
    return Rect
end


return LibRect