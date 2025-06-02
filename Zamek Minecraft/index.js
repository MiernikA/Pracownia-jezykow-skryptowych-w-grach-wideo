player.onChat("castle", function () {
    blocks.fill(WATER, pos(0, -3, 0), pos(16, -1, 16), FillOperation.Replace)
    blocks.fill(GRASS, pos(3, -3, 3), pos(13, -1, 13), FillOperation.Replace)
    blocks.fill(LOG_OAK, pos(4, -2, 4), pos(12, -1, 12), FillOperation.Replace)
    bridge()
    blocks.fill(POLISHED_ANDESITE, pos(4, 0, 4), pos(12, 4, 12), FillOperation.Replace)
    blocks.fill(AIR, pos(5, 0, 5), pos(11, 3, 11), FillOperation.Replace)
    gate()
    towers()
    windows()
})

function bridge () {
    blocks.fill(PLANKS_OAK, pos(7, -1, -2), pos(9, -1, 3), FillOperation.Replace)
    blocks.fill(LOG_OAK, pos(7, 0, -2), pos(7, 0, -2), FillOperation.Replace)
    blocks.fill(TORCH, pos(7, 1, -2), pos(7, 1, -2), FillOperation.Replace)
    blocks.fill(LOG_OAK, pos(9, 0, -2), pos(9, 0, -2), FillOperation.Replace)
    blocks.fill(TORCH, pos(9, 1, -2), pos(9, 1, -2), FillOperation.Replace)
    blocks.fill(LOG_OAK, pos(9, 0, 3), pos(9, 0, 3), FillOperation.Replace)
    blocks.fill(TORCH, pos(9, 1, 3), pos(9, 1, 3), FillOperation.Replace)
    blocks.fill(LOG_OAK, pos(7, 0, 3), pos(7, 0, 3), FillOperation.Replace)
    blocks.fill(TORCH, pos(7, 1, 3), pos(7, 1, 3), FillOperation.Replace)
    blocks.fill(OAK_FENCE, pos(7, 0, 2), pos(7, 0, -1), FillOperation.Replace)
    blocks.fill(OAK_FENCE, pos(9, 0, 2), pos(9, 0, -1), FillOperation.Replace)
}

function gate () {
    blocks.fill(AIR, pos(8, 0, 4), pos(8, 3, 4), FillOperation.Replace)
    blocks.fill(AIR, pos(7, 0, 4), pos(9, 2, 4), FillOperation.Replace)
    blocks.fill(IRON_BARS, pos(8, 3, 4), pos(8, 3, 4), FillOperation.Replace)
    blocks.fill(IRON_BARS, pos(7, 2, 4), pos(7, 2, 4), FillOperation.Replace)
    blocks.fill(IRON_BARS, pos(9, 2, 4), pos(9, 2, 4), FillOperation.Replace)
}

function windows () {
    blocks.fill(WHITE_STAINED_GLASS, pos(4, 1, 8), pos(4, 2, 8), FillOperation.Replace)
    blocks.fill(WHITE_STAINED_GLASS, pos(4, 1, 8), pos(4, 2, 8), FillOperation.Replace)
    blocks.fill(WHITE_STAINED_GLASS, pos(12, 1, 8), pos(12, 2, 8), FillOperation.Replace)
    blocks.fill(WHITE_STAINED_GLASS, pos(8, 1, 12), pos(8, 2, 12), FillOperation.Replace)
}

function towers () {
    blocks.fill(COBBLESTONE, pos(3, 0, 3), pos(5, 8, 5), FillOperation.Replace)
    blocks.fill(PLANKS_OAK, pos(3, 8, 3), pos(5, 8, 5), FillOperation.Replace)
    blocks.fill(OAK_WOOD_SLAB, pos(4, 9, 4), pos(4, 9, 4), FillOperation.Replace)
    blocks.fill(COBBLESTONE, pos(11, 0, 11), pos(13, 8, 13), FillOperation.Replace)
    blocks.fill(PLANKS_OAK, pos(11, 8, 11), pos(13, 8, 13), FillOperation.Replace)
    blocks.fill(OAK_WOOD_SLAB, pos(12, 9, 12), pos(12, 9, 12), FillOperation.Replace)
    blocks.fill(COBBLESTONE, pos(3, 0, 11), pos(5, 8, 13), FillOperation.Replace)
    blocks.fill(PLANKS_OAK, pos(3, 8, 11), pos(5, 8, 13), FillOperation.Replace)
    blocks.fill(OAK_WOOD_SLAB, pos(4, 9, 12), pos(4, 9, 12), FillOperation.Replace)
    blocks.fill(COBBLESTONE, pos(11, 0, 3), pos(13, 8, 5), FillOperation.Replace)
    blocks.fill(PLANKS_OAK, pos(11, 8, 3), pos(13, 8, 5), FillOperation.Replace)
    blocks.fill(OAK_WOOD_SLAB, pos(12, 9, 4), pos(12, 9, 4), FillOperation.Replace)
}
