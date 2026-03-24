# frozen_string_literal: true

pwd = Dir.pwd
$LOAD_PATH.unshift File.join(pwd, "src")

require "config/game_config"
require "models/player_progress"
