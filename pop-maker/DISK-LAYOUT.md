# Disk Layouts

## Track Zero

| File | Page | Sector | ProDOS Block | Staging Addr | Plain Game Addr | Copy Protect Game Addr | Copy Protect Notes |
|---|---|---|---|---|---|---|---|
| BOOT | 0 | 0 | 0.0 | $2000 | $0800 | $0800 | BOOT 0 |
| GS.EGG| 1 | 2 | 0.1 | $2100 | - | $1100 | GS Easter Egg |
| GS.EGG| 0 | 4 | 1.0 | $2200 | - | $1000 | GS Easter Egg |
| RW18 | 4 | 6 | 1.1 | $2300 | $3400 | $3400 | RW18 4 |
| RW18 | 3 | 8 | 2.0 | $2400 | $3300 | $3300 | RW18 3 |
| RW18 | 2 | 10 | 2.1 | $2500 | $3200 | $3200 | RW18 2 |
| RW18 | 1 | 12 | 3.0 | $2600 | $3100 | $3100 | RW18 1 |
| RW18 | 0 | 14 | 3.1 | $2700 | $3000 | $3000 | RW18 0 |
|  |  | 1 | 4.0 | $2800 | - | $0E00 | BOOT 6 |
|  |  | 3 | 4.1 | $2900 | - | $0D00 | BOOT 5 |
| BOOT | 5 | 5 | 5.0 | $2A00 | $0D00 | $0C00 | BOOT 4 |
| BOOT | 4 | 7 | 5.1 | $2B00 | $0C00 | - | Bit-slip Copy Protection |
| BOOT | 3 | 9 | 6.0 | $2C00 | $0B00 | $0B00 | BOOT 3 |
| BOOT | 2 | 11 | 6.1 | $2D00 | $0A00 | $0A00 | BOOT 2 |
| BOOT | 1 | 13 | 7.0 | $2E00 | $0900 | $0900 | BOOT 1 |
|  |  | 15 | 7.1 | $2F00 | x | $2F00 | Track 0 Decryption Key  |

* Staging Addr: Location in POP-Maker's staging buffer.
* Plain Game Addr: Address that non-copy protected boot loads the sector to.
* Copy Protect Addr: Addess that the copy protected boot loads the sector to.  Some of these sectors are used for copy protection.  Two are used for a GS-specific easter egg.

## Side A

|File|Dir|Track|Offset|Size|Notes|
|----|---|-----|------|----|-----|
|BOOT|obj|0|||16 sector track|
|RW18|obj|0|||16 sector track|
|HIRES|obj|1|0000|a44||
|MASTER|obj|1|0a80|776||
|HRTABLES|obj|2|0000|9b0||
|UNPACK|obj|2|0a00|399||
|TABLES|obj|3|0000|489||
|FRAMEADV|obj|3|0490|d1a||
|GRAFIX|obj|4|0000|9c0||
|TOPCTRL|obj|4|0a00|7f9||
|IMG.BGTAB1.DUN|img|5|0000|1200||
|IMG.BGTAB1.DUN||6||1160||
|IMG.CHTAB1|img|7|0000|1200||
|IMG.CHTAB1||8||11cd||
|IMG.CHTAB2|img|9|0000|1200||
|IMG.CHTAB2||10||11e5||
|IMG.CHTAB3|img|11|0000|1200||
|IMG.CHTAB3||12||561|Mixed Track|
|IMG.CHTAB5|img|12|0600|C00|Mixed Track|
|IMG.CHTAB5||13||BF6|Mixed Track|
|IMG.CHTAB4.GD|img|13|0c00|600|Mixed Track|
|IMG.CHTAB4.GD||14||F00||
|FRAMEDEF|obj|15|0000|7d1||
|SEQTABLE|obj|15|0800|9f2||
|CTRL|obj|16|0000|aff||
|COLL|obj|16|0B00|6f2||
|GAMEBG|obj|17|0000|616||
|AUTO|obj|17|0800|9c1||
|IMG.BGTAB2.DUN|img|18|0000|10cb||
|CTRLSUBS|obj|19|0200|8ff||
|SPECIALK|obj|19|0b00|526||
|VERSION|obj|19|11D8|1d||
|MUSIC.SET2|img|20|0000|400||
|SUBS|obj|20|0400|966||
|SOUND|obj|20|0e00|12f||
|MOVER|obj|21|0000|a64||
|MISC|obj|21|0b00|52c||
|STAGE1.SIDEA.DATA|img|22|0000|1200||
|STAGE1.SIDEA.DATA||23||1200||
|STAGE1.SIDEA.DATA||24||1200||
|STAGE1.SIDEA.DATA||25||1200||
|STAGE1.SIDEA.DATA||26||1200||
|STAGE1.SIDEA.DATA||27||1200||
|STAGE1.SIDEA.DATA||28||C00|Mixed Track|
|IMG.CHTAB7|img|28|0d00|483|Mixed Track|
|IMG.CHTAB6.A|img|29|0000|1200||
|IMG.CHTAB6.A||30||11f1||
|PRINCESS.SIDEA.SCENE|img|31|0000|1200||
|PRINCESS.SIDEA.SCENE||32||900|Mixed Track|
|LEVEL2|lev|32|0900|900|Mixed Track|
|LEVEL0|lev|33|0000|900||
|LEVEL1|lev|33|0900|900||
|MUSIC.SET1|img|34|0000|400||

## Side B

|File|Dir|Track|Offset|Size|Notes|Image Table Addr|
|----|---|-----|------|----|-----|-----|
|IMG.BGTAB1.PAL|img|0|0000|1200|||
|IMG.BGTAB1.PAL ||1||11E1|||
|IMG.BGTAB2.PAL|img|2|0000|11F1||8400|
|IMG.CHTAB4.SKEL|img|3|0000|1200||9600|
|IMG.CHTAB4.SKEL||4||8D|Mixed||
|IMG.CHTAB4.GD|img|4|0600|C00|Mixed|9600|
| IMG.CHTAB4.GD ||5||C00 (?)|Mixed||
|IMG.CHTAB4.FAT|img|5|0c00|600|Mixed|9600|
| IMG.CHTAB4.FAT ||6||F5D|||
|IMG.BGTAB1.DUN|img|7|0000|1200|||
| IMG.BGTAB1.DUN ||8||1160|||
|IMG.BGTAB2.DUN|img|9|0000|10CB||8400|
|IMG.CHTAB4.SHAD|img|10|0000|1200|Mixed|9600|
| IMG.CHTAB4.SHAD ||11||193|Mixed||
|IMG.CHTAB4.VIZ|img|11|0600|C00||9600|
| IMG.CHTAB4.VIZ ||12||945|Mixed||
|LOSHOW|obj|12|0c00|200|Mixed||
|EGG.LOSHOW.DAT|img|12|1000|200|Mixed||
|EGG.LOSHOW.DAT||13||1200|||
|EGG.LOSHOW.DAT||14||1200|||
|EGG.LOSHOW.DAT||15||1200|||
|EGG.LOSHOW.DAT||16||1200|||
|EGG.LOSHOW.DAT||17||1200|||
|STAGE1.SIDEB.DATA|img|18|0000|1200|||
|STAGE1.SIDEB.DATA||19||1200|||
|STAGE1.SIDEB.DATA||20||1200|||
|STAGE1.SIDEB.DATA||21||1200|||
|STAGE1.SIDEB.DATA||22||1200|||
|Saved Game Data||23|0000|1200|||
|IMG.CHTAB6.B|img|24|0000|1200|||
| IMG.CHTAB6.B ||25||D9C|||
|PRINCESS.SIDEB.SCENE|img|26|0000|1200|||
| PRINCESS.SIDEB.SCENE ||27||800|||
|LEVEL13|lev|28|0000|900|||
|LEVEL14|lev|28|0900|900|||
|LEVEL11|lev|29|0000|900|||
|LEVEL12|lev|29|0900|900|||
|LEVEL9|lev|30|0000|900|||
|LEVEL10|lev|30|0900|900|||
|LEVEL7|lev|31|0000|900|||
|LEVEL8|lev|31|0900|900|||
|LEVEL5|lev|32|0000|900|||
|LEVEL6|lev|32|0900|900|||
|LEVEL3|lev|33|0000|900|||
|LEVEL4|lev|33|0900|900|||
|MUSIC.SET3|img|24|0000|1200|||