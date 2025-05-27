local blocks = {
    -- I
    {
        shape = {
            {1, 1, 1, 1}
        },
        color = {0, 1, 1}  -- cyan
    },
    -- O
    {
        shape = {
            {1, 1},
            {1, 1}
        },
        color = {1, 1, 0}  -- yellow
    },
    -- T
    {
        shape = {
            {0, 1, 0},
            {1, 1, 1}
        },
        color = {0.6, 0, 1}  -- purple
    },
    -- J
    {
        shape = {
            {1, 0, 0},
            {1, 1, 1}
        },
        color = {0, 0, 1}  -- blue
    },
    -- L
    {
        shape = {
            {0, 0, 1},
            {1, 1, 1}
        },
        color = {1, 0.5, 0}  -- orange
    },
    -- S
    {
        shape = {
            {0, 1, 1},
            {1, 1, 0}
        },
        color = {0, 1, 0}  -- green
    },
    -- Z
    {
        shape = {
            {1, 1, 0},
            {0, 1, 1}
        },
        color = {1, 0, 0}  -- red
    }
}

return blocks
