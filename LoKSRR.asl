// Legacy of Kain: Soul Reaver Any% Glitchless Autosplitter Version 1.0 07/06/2020
// Supports real time
// Splits can be obtained from: https://www.speedrun.com/lok_sr/resources
// Original Script by Veictas
// Splits and New Script by TheDementedSalad

// Special thanks to:
// Veictas - Creator of the original script, found gameState & map
// TheDementedSalad - Found levels and no. of cutscenes for each split. Added most splits. Tested splits.

state("SRX", "Release")
{
	string10 	diaName:	0xC0160;
	byte		diaState:	0xC0194;
	
	byte 		SR1gameState: 	"sr1.dll", 0x2A7FC93; //3 Intro, 2 In Game Cutscene, 0 In Game
	byte 		SR1Cutscene: 	"sr1.dll", 0x2B1DE0; //1 Cutscene, 0 No Cutscene
	string10 	SR1map: 		"sr1.dll", 0x2A7FCA0;
	byte		SR1paused: 		"sr1.dll", 0x2A7FCB6; //6 paused 2 unpaused
	int 		SR1x: 			"sr1.dll", 0x2B65DC;
	
	byte 		SR2Cutscene: 	"sr2.dll", 0x482918; //1 Cutscene, 0 No Cutscene
	string10 	SR2map: 		"sr2.dll", 0x5E92AD8;
	byte		SR2paused: 		"sr2.dll", 0x5E92AEE; //6 paused 0 unpaused
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.Settings.CreateFromXml("Components/LoKSRR.Settings.xml");
	
	//This allows is to look through a bitmask in order to get split information
	vars.bitCheck = new Func<byte, int, bool>((byte val, int b) => (val & (1 << b)) != 0);

	vars.finalSplit = 0;
}

init
{
	switch (modules.First().ModuleMemorySize)
	{
		case (111214592):
			version = "Release";
			break;
	}
	
	vars.completedSplits = new HashSet<string>();
}

onStart
{
	//resets the splits when a new run starts
	vars.completedSplits.Clear();
	vars.finalSplit = 0;
}

update
{	
	if(settings["SR1"]){
		if(current.SR1map == "chrono1" && current.SR1gameState == 2 && old.SR1gameState == 0){
			vars.finalSplit++;
			return true;
		}
	}
	//print(modules.First().ModuleMemorySize.ToString());
}

start
{
	return current.SR1Cutscene == 1 && old.SR1Cutscene == 0 && current.SR1map == "under1" || current.SR2Cutscene == 1 && old.SR2Cutscene == 0 && current.SR2map == "strong1A";
}

split
{
	
	string setting = "";
	
	if(settings["SR1"]){
		if(current.SR1map != old.SR1map || current.SR1gameState != old.SR1gameState){
			setting = "Area_" + current.SR1map + "_" + current.SR1gameState;
		}
		
		if((current.SR1map == "cathy60" || current.SR1map == "cathy76") && current.SR1gameState == 2){
			setting = "glass1";
		}
	
		if((current.SR1map == "cathy59" || current.SR1map == "cathy75") && current.SR1gameState == 2){
			setting = "glass2";
		}
	
		if(current.SR1map == "cathy42" && current.SR1gameState == 2 && current.SR1x == -812){
			setting = "valve2";
		}
		
		if(current.SR1map == "cathy46" && current.SR1gameState == 2 && current.SR1x == -4707){
			setting = "valve3";
		}
		
		if(current.SR1map == "chrono1" && vars.finalSplit == 3 && current.SR1gameState == 2 && old.SR1gameState == 0){
			return true;
		}
	}
	
	if(current.diaName != old.diaName || current.diaState != old.diaState){
		setting = "Dialogue_" + current.diaName + "_" + current.diaState;
	}
	
	// Debug. Comment out before release.
	if (!string.IsNullOrEmpty(setting))
	vars.Log(setting);

	if (settings.ContainsKey(setting) && settings[setting] && vars.completedSplits.Add(setting)){
		return true;
	}
}

isLoading
{
	return current.SR1paused == 6 || current.SR2paused == 6;
}

reset
{
	return current.diaName == "KAININT" && old.diaName != "KAININT" || current.diaName == "SR2INTRO" && old.diaName != "SR2INTRO";
}