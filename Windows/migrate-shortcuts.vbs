' migrate-shortcuts.vbs
' 8/19/2018
' Gabe Feindel
' Could be generalized to replace any substring for future migrations.

On Error Resume Next

Const ALL_USERS_DESKTOP = &H19&
Const USER_DESKTOP = &H00&

Set objShell = CreateObject("Shell.Application")
Set objFolder = objShell.Namespace(USER_DESKTOP)

strOld = Wscript.Arguments(0)
strNew = Wscript.Arguments(1)

wscript.echo "Old Path: " & strOld
wscript.echo "New Path: " & strNew

set objFiles = objFolder.Items
for each objFile in objFiles
    if objFile.IsLink then
        Wscript.Echo "Found shortcut: " & objFile.Name
        set objShortcut = objFolder.ParseName(objFile.Path)
        set objLink = objShortcut.GetLink
        if InStr(1,objLink.Path,strOld,1)>0 then
            wscript.echo "Shortcut refers to " & objLink.Path
            newlinkPath = Replace(objLink.Path,strOld,strNew,1,-1,1)
	    Wscript.Echo "New path: " & newLinkPath
            objLink.Path = newlinkPath
            objLink.Save()
        end if

    end if
Next
