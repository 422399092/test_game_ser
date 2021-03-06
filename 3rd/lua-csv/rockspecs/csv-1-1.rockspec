package = "csv"
version = "1-1"
source =
{
  url = "git://github.com/geoffleyland/lua-csv.git",
  branch = "master",
  tag = "v1",
}
description =
{
  summary = "CSV and other delimited file reading",
  homepage = "http://github.com/geoffleyland/lua-csv",
  license = "MIT/X11",
  maintainer = "Geoff Leyland <geoff.leyland@incremental.co.nz>"
}
dependencies = { "lua >= 5.1" }
build =
{
  type = "builtin",
  modules =
  {
    csv = "lua/csv.lua",
  },
}
