#DECLARE($name : Text)->$file : 4D.File

// Samples live in the host project's Resources folder. Always hand the
// component a 4D.File: a Text path is taken literally by the CLI, so
// "/RESOURCES/..." as text would point inside the component bundle.

$file:=Folder("/RESOURCES/samples").file($name)
