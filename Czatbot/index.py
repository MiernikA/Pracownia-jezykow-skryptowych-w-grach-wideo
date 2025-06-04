import os
import discord
import ollama
import random
from discord.ext import commands

tournaments = {
    "CS": {"players": [], "pairs": [], "round": 1},
    "LOL": {"players": [], "pairs": [], "round": 1}
}

intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents, help_command=None)

def query_llm(prompt):
    response = ollama.chat(model="llama3", messages=[{"role": "user", "content": prompt}])
    return response['message']['content']

@bot.command(name="help")
async def custom_help(ctx):
    help_text = (
        "**Available Commands:**\n"
        "`!help` - Displays this help message\n"
        "`!tournaments` - Shows the list of available tournaments\n"
        "`!join <game> <nickname>` - Adds a player to the selected tournament\n"
        "`!getpairs <game>` - Randomly creates player matchups\n"
        "`!nextround <game>` - Runs the next round and eliminates losers\n"
        "`!status` - Shows the current status of all tournaments"
    )
    await ctx.send(help_text)


@bot.command(name="tournaments")
async def show_tournaments(ctx):

    games = list(tournaments.keys())
    formatted_games = "\n".join(f" - {game}" for game in games)
    prompt = "Write a short exciting message about a 1 vs 1 e-sport tournament, focused on competition and team spirit."
    intro_message = query_llm(prompt)

    message = f"{intro_message}\n\n🎯 Available tournaments:\n{formatted_games}"
    await ctx.send(f" {message}")


@bot.command(name="join")
async def join_tournament(ctx, game: str, nickname: str):
    normalized_game = None
    for key in tournaments:
        if key.lower() == game.lower():
            normalized_game = key
            break

    if not normalized_game:
        await ctx.send("❌ There is no tournament like this. Try again!")
        return

    player_number = len(tournaments[normalized_game]["players"]) + 1
    tournaments[normalized_game]["players"].append({"nick": nickname, "id": player_number})

    prompt = f"Confirm that player '{nickname}' with number {player_number} has joined the '{normalized_game}' tournament. Don't analyse it, just write a welcome message."
    welcome_message = query_llm(prompt)

    player_nicks = [f"{player['nick']}#{player['id']}" for player in tournaments[normalized_game]["players"]]
    nick_list = ", ".join(player_nicks)

    message = f"{welcome_message}\nCurrently registered players: {nick_list}"
    await ctx.send(f"✅ {message}")


@bot.command(name="getpairs")
async def get_pairings(ctx, game: str):
    normalized_game = None
    for key in tournaments:
        if key.lower() == game.lower():
            normalized_game = key
            break

    if not normalized_game:
        await ctx.send("❌ There is no tournament like this. Try again!")
        return

    players = tournaments[normalized_game]["players"][:]
    random.shuffle(players)
    pairs = []
    while len(players) > 1:
        pairs.append((players.pop(), players.pop()))
    if players:
        pairs.append((players.pop(), {"nick": "FREE", "id": 0}))
    tournaments[normalized_game]["pairs"] = pairs

    lines = []
    for a, b in pairs:
        if a['nick'] == "FREE" or b['nick'] == "FREE":
            prompt = "Say something like 'This one does need to fight, he gets a free win'"
            teaser = query_llm(prompt).strip().strip('\'"')
            winner = b if a['nick'] == "FREE" else a
            lines.append(f"{teaser}\n\n{winner['nick']}#{winner['id']}\n\n")
        else:
            prompt = "Create a 1 short generic sentence about duel, something alike 'this is gonna be huge fight'"
            teaser = query_llm(prompt).strip().strip('\'"')
            lines.append(f"{teaser}\n\n{a['nick']}#{a['id']} ⚔️ {b['nick']}#{b['id']}\n\n")

    message = "\n".join(lines)
    await ctx.send(message)


@bot.command(name="nextround")
async def next_round(ctx, game: str):
    normalized_game = None
    for key in tournaments:
        if key.lower() == game.lower():
            normalized_game = key
            break

    if not normalized_game:
        await ctx.send("❌ No such tournament. Please try again.")
        return

    pairs = tournaments[normalized_game]["pairs"]
    if not pairs:
        await ctx.send("❌ No pairings found. Use !getpairs first.")
        return

    survivors = []
    for a, b in pairs:
        if a['nick'] == "FREE":
            survivors.append(b)
            await ctx.send(f"🎉 {b['nick']}#{b['id']} advances to the next round (FREE WIN)!")
        elif b['nick'] == "FREE":
            survivors.append(a)
            await ctx.send(f"🎉 {a['nick']}#{a['id']} advances to the next round (FREE WIN)!")
        else:
            await ctx.send(f"Who won the duel? 🔥 {a['nick']}#{a['id']} vs {b['nick']}#{b['id']}\nReply `1` if {a['nick']} won, `2` if {b['nick']} won.")

            def check(m):
                return m.author == ctx.author and m.channel == ctx.channel and m.content in ["1", "2"]

            msg = await bot.wait_for('message', check=check, timeout=60.0)
            winner = a if msg.content == "1" else b
            survivors.append(winner)
            await ctx.send(f"✅ {winner['nick']}#{winner['id']} advances to the next round!")

    tournaments[normalized_game]["players"] = survivors
    tournaments[normalized_game]["round"] += 1
    tournaments[normalized_game]["pairs"] = []

    if len(survivors) == 1:
        winner = survivors[0]
        prompt = f"Write a short, dramatic announcement for the winner of a tournament called {normalized_game}, with the winner being {winner['nick']}#{winner['id']}."
        teaser = query_llm(prompt).strip().strip('\'"')
        await ctx.send(f"🏆 {teaser}")
    else:
        player_nicks = [f"{p['nick']}#{p['id']}" for p in survivors]
        nick_list = ", ".join(player_nicks)
        prompt = f"Write a short exciting line announcing that the following players advance to the next round: {nick_list}."
        teaser = query_llm(prompt).strip().strip('\'"')
        await ctx.send(f"🟢 {teaser}")


@bot.command(name="status")
async def tournament_status(ctx):
    if not tournaments:
        await ctx.send("There are no tournaments at the moment.")
        return

    lines = []
    for name, data in tournaments.items():
        player_list = ", ".join(f"{p['nick']}#{p['id']}" for p in data["players"]) or "No players yet"
        round_num = data["round"]
        lines.append(f"🎮 **{name}** — Round {round_num}\nPlayers: {player_list}\n")

    await ctx.send("\n".join(lines))


bot.run(os.getenv("DISCORD_TOKEN"))
