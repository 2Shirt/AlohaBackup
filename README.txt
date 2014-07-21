Aloha Backup - A script for automating AlohaQS backups.

There are five types of backups that this script can perform:
	Full:
		Contents:	The whole AlohaQS folder.
		Name:		YYYY_MM_DD.7z
	Monthly:
		Contents:	All "YYYYMMDD" folders from the previous month.
		Name:		YYYY_MM.7z
	Nightly:
		Contents:	The "YYYYMMDD" folder for yesterday.
		Name:		YYYY_MM_DD.7z
	Program:
		Contents:	Everything but the "YYYYMMDD" folders.
		Name:		YYYY_MM_DD.7z
	Yearly:
		Contents:	All "YYYYMMDD" folders from a year (determined by the filename).
		Name:		YYYY.7z
*   All backups are compressed with 7-Zip to save space. Backups are less than 20% original size!
**  All filenames refer to the dates contained in the backup except the Full and Program backups; those refer to when the backup was done.


Installation:
Make a folder named "Aloha Backups" at the root of a drive.
    e.g. "D:\Aloha Backups" or "F:\Aloha Backups"
    The drive can be a local HD, USB Stick, or Network Share.
(Optional) Copy the "Copy Backups to Desktop.cmd" file to the root of the same drive.
    This file is useful if your backups are on a USB stick and you want to keep an additional backup on another PC.
Then copy the files to any folder and run Aloha_Backup.cmd
*   If you don't copy the 7za folder, you will need to install 7-Zip.


Usage:
    Aloha_Backup.cmd mode [options]
    Aloha_Backup.cmd /help

    Options:
      /h /help     Show this screen.
      /s           Silent ^(Suppress messages^).

    Modes:
      Nightly     Backup yesterday
      Monthly     Backup last month
      Yearly      Backup last year
      Program     Backup program files
      Full        Backup everything


7-Zip is Copyright Igor Pavlovis www.7-zip.org
7-zip is covered under an LGPL, see license.txt for details.