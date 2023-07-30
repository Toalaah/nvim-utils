{
  runCommand,
  docs,
}:
runCommand "documentation.md" {} ''
  cat ${docs.optionsCommonMark} >> $out
''
