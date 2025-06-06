import os
import discord
import ollama
import random
from discord.ext import commands
from dotenv import load_dotenv

tournaments = {
    "CS": {"players": [], "pairs": [], "round": 1},
    "LOL": {"players": [], "pairs": [], "round": 1}
}

intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents, help_command=None)

def query_llm(prompt):
    response = ollama.chat(model="llama3", messages=[{"role": "user", "content": prompt}])
    content = response['message']['content'].strip()

    if (content.startswith('"') and content.endswith('"')) or (content.startswith("'") and content.endswith("'")):
        content = content[1:-1].strip()

    return content

@bot.command(name="tournaments")
async def show_tournaments(ctx):
    games = list(tournaments.keys())
    formatted_games = "\n".join(f" - {game}" for game in games)
    prompt = "Write a one-sentence, enthusiastic introduction encouraging users to join the CS or LOL tournaments."

    try:
        intro = query_llm(prompt)
    except Exception:
        intro = "🎮 Check out the available tournaments and join the fun!"

    await ctx.send(f"{intro}\n\n🎯 Available tournaments:\n{formatted_games}")

@bot.command(name="join")
async def join_tournament(ctx, game: str, nickname: str):
    normalized_game = next((k for k in tournaments if k.lower() == game.lower()), None)

    if not normalized_game:
        await ctx.send("❌ No such tournament.")
        return

    player_number = len(tournaments[normalized_game]["players"]) + 1
    tournaments[normalized_game]["players"].append({"nick": nickname, "id": player_number})

    player_nicks = [f"{p['nick']}#{p['id']}" for p in tournaments[normalized_game]["players"]]
    nick_list = ", ".join(player_nicks)

    await ctx.send(f"✅ {nickname}#{player_number} joins the {normalized_game} tournament!\n\nCurrent players: {nick_list}")

@bot.command(name="getpairs")
async def get_pairings(ctx, game: str):
    normalized_game = next((k for k in tournaments if k.lower() == game.lower()), None)

    if not normalized_game:
        await ctx.send("❌ No such tournament.")
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
            winner = b if a['nick'] == "FREE" else a
            lines.append(f"🎉 {winner['nick']}#{winner['id']} advances to the next round with a free pass! 🎉")
        else:
            lines.append(f"🔥 {a['nick']}#{a['id']} will battle {b['nick']}#{b['id']}! 🔥")

    await ctx.send("\n".join(lines))

@bot.command(name="playround")
async def next_round(ctx, game: str):
    normalized_game = next((k for k in tournaments if k.lower() == game.lower()), None)

    if not normalized_game:
        await ctx.send("❌ No such tournament.")
        return

    pairs = tournaments[normalized_game]["pairs"]
    if not pairs:
        await ctx.send("❌ Use !getpairs first.")
        return

    survivors = []
    for a, b in pairs:
        if a['nick'] == "FREE":
            survivors.append(b)
            await ctx.send(f"🎉 {b['nick']}#{b['id']} advances (free pass)!")
        elif b['nick'] == "FREE":
            survivors.append(a)
            await ctx.send(f"🎉 {a['nick']}#{a['id']} advances (free pass)!")
        else:
            await ctx.send(f"Who won? 🔥 {a['nick']}#{a['id']} vs {b['nick']}#{b['id']} (reply with `1` or `2`)")

            def check(m):
                return m.author == ctx.author and m.channel == ctx.channel and m.content in ["1", "2"]

            msg = await bot.wait_for('message', check=check, timeout=60.0)
            winner = a if msg.content == "1" else b
            survivors.append(winner)
            await ctx.send(f"✅ {winner['nick']}#{winner['id']} advances!")

    tournaments[normalized_game]["players"] = survivors
    tournaments[normalized_game]["round"] += 1
    tournaments[normalized_game]["pairs"] = []

    if len(survivors) == 1:
        winner = survivors[0]
        intro_prompt = f"Write a short, one-sentence message about e-sport tournament winner, dont assume game or nick - be as generic as possible"
        try:
            intro = query_llm(intro_prompt)
        except Exception:
            intro = "\n And now, the moment we've all been waiting for!"

        await ctx.send(f"{intro}\n\n🏆 The winner of the {normalized_game} tournament is {winner['nick']}#{winner['id']}!")
    else:
        player_nicks = [f"{p['nick']}#{p['id']}" for p in survivors]
        nick_list = ", ".join(player_nicks)
        await ctx.send(f"🟢 Advancing to the next round: {nick_list}")

@bot.command(name="status")
async def tournament_status(ctx):
    if not tournaments:
        await ctx.send("No active tournaments.")
        return

    lines = []
    for name, data in tournaments.items():
        player_list = ", ".join(f"{p['nick']}#{p['id']}" for p in data["players"]) or "No players"
        round_num = data["round"]
        lines.append(f"🎮 **{name}** — Round {round_num}\nPlayers: {player_list}")

    await ctx.send("\n".join(lines))


@bot.event
async def on_message(message):
    if message.author.bot or message.webhook_id is not None:
        return

    ctx = await bot.get_context(message)

    if ctx.valid:
        await bot.process_commands(message)
        return

    prompt = f"""
Available commands: !join <game> <nickname>, !getpairs <game>, !playround <game>, !status, !tournaments.
Available games: CS, LOL.

tournaments - about games that are avaiable to join
join – used when a user wants to sign up someone or themselves for a tournament.
getpairs – used when asking who will play with whom, or suggesting a pairing.
playround – used when asking whether the tournament can proceed, or asking about the next round or who won
status – used to ask who is playing in which tournament, what the game status is, etc.

The user wrote: "{message.content}"
Return only the command (e.g., !join CS Adam), or none if it's unclear.
"""
    try:
        suggested_command = query_llm(prompt).strip().strip("`")
        if suggested_command.lower() == "none":
            await message.channel.send("🤖 I don't understand. Use `!help` to see available commands.")
            return

        message.content = suggested_command
        await bot.process_commands(message)
    except Exception as e:
        await message.channel.send(f"⚠️ Interpretation error: {str(e)}")

load_dotenv()
bot.run(os.getenv("DISCORD_TOKEN"))
