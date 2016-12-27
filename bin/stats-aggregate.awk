BEGIN {
}

function getExtension(str){
  n = split(str, parts, ".")
  if (n == 1){
    return "<NO EXTENSION>"
  } else {
    return parts[n]
  }
}

$2 != "total" {
  by_type[getExtension($2)] += $1
}

$2 ~ "CMakeLists.txt" {
  #cmake should not count as text
  by_type["txt"] -= $1
  by_type["cmake"] += $1
}

$2 ~ "test" {
  by_type[getExtension($2)] -= $1
  by_type["TEST"] += $1
}

END {

  # join up cpp types
  by_type["cpp"] += by_type["hpp"]
  delete by_type["hpp"]

  #get rid of some filetypes I dont care about
  delete by_type["gitignore"]
  delete by_type["jpg"]
  delete by_type["png"]
  delete by_type["ttf"]
  delete by_type["pdf"]

  #print each getExtension, collect the total
  total=0
  for (x in by_type) {
    if (by_type[x] > 0) {
      total += by_type[x]
      print (x, by_type[x])
    }
  }

  print("Total:", total)
}
