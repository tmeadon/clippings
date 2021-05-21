Configuration MyFolderConfig
{
    Import-DscResource -ModuleName MyFileSystem

    MyFolder Create
    {
        Ensure = 'Absent'
        Path = 'C:\dir'
    }
}

MyFolderConfig