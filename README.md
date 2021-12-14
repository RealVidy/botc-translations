# BotcTranslations

This repo contains scripts to generate JSON files for use on [clocktower.online](https://clocktower.online/) or [Nara](https://nara.fly.dev/) as well as CSV files for the google sheet in which we keep translations for abilities, names, and various reminders.

You can find already generated JSON files in [assets/generated_json](assets/generated_json) and the google sheet is [here](https://docs.google.com/spreadsheets/d/183HMp4ZgslxA4NtFVTXhY3xAbg7FIXZdmVnh9-4A_14/edit#gid=923580658).

The language we use is Elixir (see how to [install](https://elixir-lang.org/install.html#macos) it).

## Google Sheet / CSV

We use a google sheet to edit, discuss, and maintain translations of the game, mainly for digital use on [clocktower.online](https://clocktower.online/) or [Nara](https://nara.fly.dev/). This format should also be usable to generate translations for the physical copy of the game one day.

Take a look at the english tab which you will need to duplicate for your own language: [EN](https://docs.google.com/spreadsheets/d/183HMp4ZgslxA4NtFVTXhY3xAbg7FIXZdmVnh9-4A_14/edit#gid=1546765235). We download these tabs in CSV format and run our script on them to generate JSON files.

![](assets/images/download_tab_csv.png)

## Running the scripts

### From CSV to JSON

Once we have the CSV file for our language, we can run a script that will generate a JSON file in the clocktower.online format.

```bash
mix run generate_json_from_csv.exs assets/csv/<LOCALE>.csv
```

The result will be at `assets/generated_json/roles_<LOCALE>.json`

Try it out with the french file: 
```bash
mix run generate_json_from_csv.exs assets/csv/fr_fr.csv
```

### From JSON to CSV

If you already have the JSON file containing all roles for your language, then you can also transform it into a CSV and import it in the [google sheets](https://docs.google.com/spreadsheets/d/183HMp4ZgslxA4NtFVTXhY3xAbg7FIXZdmVnh9-4A_14/edit#gid=923580658)

```bash
mix run generate_csv_from_json.exs assets/json/<LOCALE>.json
```

The result will be at `assets/generated_csv/<LOCALE>.csv`

Try it out with the english file: 
```bash
mix run generate_csv_from_json.exs assets/json/en.json
```

## Using the generated JSON

The generated json files match the format used on clocktower.online. 

You can use them directly as custom scripts (but every role will be available in your game, which is maybe a bit much!) or you can remove the roles you don't want before using them as custom scripts.

We will work on helping you generate ready-made scripts soon (see [Contributions](#contributions))

## Contributions

The best way to help is to add your language to the google sheet (by duplicating [EN](https://docs.google.com/spreadsheets/d/183HMp4ZgslxA4NtFVTXhY3xAbg7FIXZdmVnh9-4A_14/edit#gid=1546765235)) and then pinging [RealVidy#2485](https://discordapp.com/users/668940363196792849) on Discord.

If you want to help with development, we need a way to generate custom scripts with the translations (which is actually easily done, ask [RealVidy#2485](https://discordapp.com/users/668940363196792849) on Discord!)
