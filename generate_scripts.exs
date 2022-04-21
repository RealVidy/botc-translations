require Logger

# This script will generate script JSON files for clocktower.online and Nara from the JSON files containing all roles for each locale

# Usage: mix run generate_scripts.exs

defmodule GenerateScripts do
  @path_to_scripts "assets/scripts"
  @path_to_script_definitions "assets/script_definitions"
  @path_to_json_roles "assets/json"

  # Main function
  def generate() do
    all_locales =
      "assets/json"
      |> File.ls!()
      |> Enum.map(fn path ->
        Path.rootname(path)
      end)
      |> Enum.reject(fn locale -> locale == "" end)

    script_paths = Path.wildcard("#{@path_to_script_definitions}/*.json")

    script_roles =
      Enum.reduce(script_paths, %{}, fn script_path, acc ->
        script_role =
          script_path
          |> File.read!()
          |> Jason.decode!()

        script_name =
          script_path
          |> Path.basename()
          |> Path.rootname()

        Map.put(acc, script_name, script_role)
      end)

    Enum.each(all_locales, fn locale ->
      generate_scripts_for_locale(locale, script_roles)
    end)
  end

  defp generate_scripts_for_locale(locale, script_roles) do
    locale_roles = load_locale_roles(locale)

    folder = "#{@path_to_scripts}/#{locale}"
    File.mkdir_p(folder)

    Enum.each(script_roles, fn {script_name, role_ids} ->
      file_name = "#{script_name}.json"
      path = "#{folder}/#{file_name}"

      built_script = Enum.map(role_ids, fn role_id -> locale_roles[role_id] end)
      result_json = Jason.encode!(built_script)

      File.write!(path, result_json)
      bin_path = "#{File.cwd!()}/format_json.sh"

      System.cmd(bin_path, [folder, file_name])
    end)

    Logger.info("Script files generated in: #{folder}\n")
  end

  defp load_locale_roles(locale) do
    flat_locale_roles =
      "#{@path_to_json_roles}/#{locale}.json"
      |> File.read!()
      |> Jason.decode!()

    Enum.reduce(flat_locale_roles, %{}, fn role, acc ->
      role_id = role["id"]

      # Add the locale to the id so that clocktower.online doesn't fail to show the localized version of the role
      updated_role = Map.put(role, "id", "#{locale}_#{role_id}")
      Map.put(acc, role_id, updated_role)
    end)
  end
end

GenerateScripts.generate()
