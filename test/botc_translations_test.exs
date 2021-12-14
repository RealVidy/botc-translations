defmodule BotcTranslationsTest do
  use ExUnit.Case
  doctest BotcTranslations

  test "greets the world" do
    assert BotcTranslations.hello() == :world
  end
end
