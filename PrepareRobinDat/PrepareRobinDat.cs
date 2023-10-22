namespace PrepareRobinDat;

class LevelInfo
{
    public int ScrBlock;   // Начальный блок сжатого экрана
    public int ScrSize;    // Размер сжатого экрана, байт
    public int ExtBlock;   // Начальный блок сжатых вставок 
    public int ExtSize;    // Размер сжатых вставок, байт
    public int CodeBlock;  // Начальный блок код+текст
    public int CodeSize;   // Размер код+текст, байт
}

class Program
{
    static void Main(string[] args)
    {
        // Готовим общий файл ROBIN.DAT, включающий все уровни
        // на каждый уровень: сжатый экран, сжатые вставки, код + текст

        Console.WriteLine($" Scr |   ScrLz | ScrExLz | Cod+Txt |   Total Blocks ");
        var bytesAll = new List<byte>();

        // Сначала сжатый заголовочный экран
        var binTitleLz = File.ReadAllBytes("TITLZ.BIN");
        bytesAll.AddRange(binTitleLz);
        AlignToBlock(bytesAll);
        Console.WriteLine($"title    {binTitleLz.Length,5}       ---     ---       {bytesAll.Count,5}  {bytesAll.Count / 512,5}");

        // Затем все уровни
        var infos = new List<LevelInfo>();
        for (int scrno = 1; scrno <= 7; scrno++)
        {
            var bytes = new List<byte>();
            var binScrLz = File.ReadAllBytes($"SCR{scrno}LZ.BIN");
            var binScrLzSize = binScrLz.Length;
            bytes.AddRange(binScrLz);
            AlignToBlock(bytes);
            var binScrExLz = File.ReadAllBytes($"SCX{scrno}LZ.BIN");
            bytes.AddRange(binScrExLz);
            var binScrLzExSize = binScrExLz.Length;
            AlignToBlock(bytes);
            var binSav = File.ReadAllBytes($"ROBIN{scrno}.SAV").ToList();
            binSav.RemoveRange(0, 4096); // 010000
            bytes.AddRange(binSav);
            var info = new LevelInfo()
            {
                ScrBlock = bytesAll.Count / 512,
                ScrSize = binScrLzSize,
                ExtSize = binScrLzExSize,
                CodeSize = binSav.Count
            };
            info.ExtBlock = info.ScrBlock + (binScrLzSize + 511) / 512;
            info.CodeBlock = info.ExtBlock + (binScrLzExSize + 511) / 512;
            infos.Add(info);
            bytesAll.AddRange(bytes);
            Console.WriteLine($"  {scrno}      {binScrLzSize,5}     {binScrLzExSize,5}    {binSav.Count,5}      {bytes.Count,5}  {bytes.Count / 512,5}");
        }
        
        Console.WriteLine($" TOTAL:                               {bytesAll.Count,6}  {bytesAll.Count / 512,5}");
        File.WriteAllBytes("ROBIN.DAT", bytesAll.ToArray());
        Console.WriteLine($"Saved ROBIN.DAT, {bytesAll.Count} bytes");

        var levelsLines = new List<string>();
        levelsLines.Add($"TITLZS = {binTitleLz.Length}.");
        levelsLines.Add("");
        levelsLines.Add("LEVELS:: ; ScrBlk, ScrSize, ExtBlk, ExtSize, CodeBlk, CodeSize");
        for (var scrno = 1; scrno <= infos.Count; scrno++)
        {
            var info = infos[scrno - 1];
            var s = $"\t.WORD\t" +
                    $"{info.ScrBlock,3}., {(info.ScrSize + 1) / 2,5}., " +
                    $"{info.ExtBlock,5}., {(info.ExtSize + 1) / 2,5}., " +
                    $"{info.CodeBlock,5}., {(info.CodeSize + 1) / 2,5}." +
                    $"\t; Level {scrno}";
            levelsLines.Add(s);
        }

        File.WriteAllLines("LEVELS.MAC", levelsLines);
        Console.WriteLine("Saved LEVELS.MAC");
    }

    static void AlignToBlock(List<byte> bytes)
    {
        var gap = 512 - bytes.Count % 512;
        if (gap == 512)
            return;
        for (int i = 0; i < gap; i++)
            bytes.Add(0);
    }        
}
