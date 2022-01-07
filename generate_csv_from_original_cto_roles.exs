require Logger

# This file is used to generate the "en_UK" tab template for https://docs.google.com/spreadsheets/d/1ksIW9R3xkP-RHT4iGDAsKom8LVlPiXIphvDedApumT0/edit#gid=645798193
# It takes `roles.json` from bra1n's Townsquare as input (stored as `assets/json/en_UK.json` in this repo)

role_ids = [
  "acrobat",
  "alchemist",
  "alhadikhia",
  "amnesiac",
  "angel",
  "artist",
  "assassin",
  "atheist",
  "balloonist",
  "barber",
  "baron",
  "boomdandy",
  "bountyhunter",
  "buddhist",
  "butler",
  "cannibal",
  "cerenovus",
  "chambermaid",
  "chef",
  "choirboy",
  "clockmaker",
  "courtier",
  "cultleader",
  "damsel",
  "devilsadvocate",
  "djinn",
  "doomsayer",
  "dreamer",
  "drunk",
  "duchess",
  "empath",
  "engineer",
  "eviltwin",
  "exorcist",
  "fanggu",
  "farmer",
  "fearmonger",
  "fibbin",
  "fiddler",
  "fisherman",
  "flowergirl",
  "fool",
  "fortuneteller",
  "gambler",
  "general",
  "goblin",
  "godfather",
  "golem",
  "goon",
  "gossip",
  "grandmother",
  "hellslibrarian",
  "heretic",
  "huntsman",
  "imp",
  "innkeeper",
  "investigator",
  "juggler",
  "king",
  "klutz",
  "legion",
  "leviathan",
  "librarian",
  "lilmonsta",
  "lleech",
  "lunatic",
  "lycanthrope",
  "magician",
  "marionette",
  "mastermind",
  "mathematician",
  "mayor",
  "mezepheles",
  "minstrel",
  "monk",
  "moonchild",
  "mutant",
  "noble",
  "nodashii",
  "oracle",
  "pacifist",
  "philosopher",
  "pithag",
  "pixie",
  "po",
  "poisoner",
  "politician",
  "poppygrower",
  "preacher",
  "professor",
  "psychopath",
  "pukka",
  "puzzlemaster",
  "ravenkeeper",
  "recluse",
  "revolutionary",
  "riot",
  "sage",
  "sailor",
  "saint",
  "savant",
  "scarletwoman",
  "seamstress",
  "sentinel",
  "shabaloth",
  "slayer",
  "snakecharmer",
  "snitch",
  "soldier",
  "spiritofivory",
  "spy",
  "stormcatcher",
  "sweetheart",
  "tealady",
  "tinker",
  "towncrier",
  "toymaker",
  "undertaker",
  "vigormortis",
  "virgin",
  "vortox",
  "washerwoman",
  "widow",
  "witch",
  "zombuul"
]

headers = [
  "id",
  "name",
  "ability",
  "firstNightReminder",
  "otherNightReminder",
  "remindersGlobal",
  "reminders"
]

reversed_headers = Enum.reverse(headers)

defmodule Formatting do
  def col_to_csv(_header, nil), do: nil

  def col_to_csv(header, col) when header in ["reminders", "remindersGlobal"] do
    Enum.join(col, ",")
  end

  def col_to_csv(_header, col) do
    col
  end
end

co_roles =
  "assets/json/en_UK.json"
  |> File.read!()
  |> Jason.decode!()
  |> Enum.reduce(%{}, fn co_role, acc -> Map.put(acc, co_role["id"], co_role) end)

rows =
  Enum.map(role_ids, fn role_id ->
    co_role = co_roles[role_id]

    Enum.reduce(reversed_headers, [], fn header, acc ->
      [Formatting.col_to_csv(header, co_role[header]) | acc]
    end)
  end)

file =
  File.open!("assets/csv/en_UK.csv", [
    :write,
    :utf8
  ])

[headers | rows] |> CSV.encode() |> Enum.each(&IO.write(file, &1))
