require Logger

defmodule Uploader do
  @username System.fetch_env!("BOTC_SCRIPTS_USERNAME")
  @pwd System.fetch_env!("BOTC_SCRIPTS_PWD")

  def iterate_json(json_path) do
    Logger.info("Starting to process #{inspect(json_path, pretty: true)}\n")

    locale =
      json_path
      |> Path.rootname()
      |> Path.basename()

    roles =
      json_path
      |> File.read!()
      |> Jason.decode!()

    Enum.each(roles, fn role ->
      role_id = Constants.normalize_role_id(role["id"])
      botc_scripts_role = to_botc_script_role(role)
      Logger.info(" botc_scripts_role #{inspect(botc_scripts_role, pretty: true)}\n")
      upload_role(locale, role_id, Jason.encode!(botc_scripts_role))
    end)
  end

  defp to_botc_script_role(role) do
    global_reminders =
      if role["remindersGlobal"] != nil, do: Enum.join(role["remindersGlobal"], ","), else: nil

    reminders = if role["reminders"] != nil, do: Enum.join(role["reminders"], ","), else: nil

    %{
      character_name: role["name"],
      ability: role["ability"],
      first_night_reminder: role["firstNightReminder"],
      other_night_reminder: role["otherNightReminder"],
      global_reminders: global_reminders,
      reminders: reminders
    }
  end

  defp upload_role(locale, role_id, body) do
    with {:ok, %HTTPoison.Response{status_code: 500}} <-
           HTTPoison.post(
             "https://botc-scripts.azurewebsites.net/api/translations/#{locale}/#{role_id}/",
             body,
             [{"Content-Type", "application/json"}],
             hackney: [basic_auth: {@username, @pwd}]
           ) do
      Logger.warn("POST failed for #{role_id}, trying PUT\n")

      HTTPoison.put!(
        "https://botc-scripts.azurewebsites.net/api/translations/#{locale}/#{role_id}/",
        body,
        [{"Content-Type", "application/json"}],
        hackney: [basic_auth: {@username, @pwd}]
      )
    end
  end
end

Constants.get_known_locales()
|> Enum.reject(fn locale -> locale == "en_GB" end)
|> Enum.each(fn locale ->
  path = "assets/json/#{locale}.json"
  Uploader.iterate_json(path)
end)
