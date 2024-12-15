// Legacy of Kain: Soul Reaver 1 & 2 Remaster Autosplitter Version 1.0 13 Dec 2024
// By TheDementedSalad
//Supports Load Remover
//Autosplitter for SR1 & 2


// Special thanks to:
// TheDementedSalad - Created Splitter
// Gemini REbirth - Dev for the game, helped with finding addresses and info for them

state("SRX", "Release")
{
	//string10 	diaName:	0xC0160;
	//byte		diaState:	0xC0194;
	
	byte 		SR1Cutscene: 	"sr1.dll", 0x2B1DE0; //1 Cutscene, 0 No Cutscene
	//string10 	SR1map: 		"sr1.dll", 0x2A7FCA0;
	//byte		SR1paused: 		"sr1.dll", 0x2A7FCB6; //6 paused 2 unpaused
	int 		SR1x: 			"sr1.dll", 0x2B65DC;
	
	byte 		SR2Cutscene: 	"sr2.dll", 0x482918; //1 Cutscene, 0 No Cutscene
	string10 	SR2map: 		"sr2.dll", 0x5E92AD8;
	byte		SR2paused: 		"sr2.dll", 0x5E92AEE; //6 paused 0 unpaused
	int			SR2Info: 		"sr2.dll", 0x5E92268; //bit 0 Pass Through Walls, bit 1 Wall Crawling, bit 2 Force, bit 3 Soul Reaver, bit 4 Swim, bit 5 Constrict, bit 7 SR2Health
	
	/* Extra Info on Bits
	byte		SR2I2: 		"sr2.dll", 0x5E92269; //bit 1 Blood Reaver, bit 2 Spectral, bit 3 Material, bit 4 Dark, bit 5 Light, bit 6 Air, bit 7 Fire
	byte		SR2I3: 		"sr2.dll", 0x5E9226A; //bit 0 Water Reaver, bit 1 Earth, bit 2 Spirit, bit 3 Plane Shift Glyph, bit 4 Soul Reaver Glyph, bit 5 Dimension, bit 6 Time, bit 7 Mind
	byte		SR2I4: 		"sr2.dll", 0x5E9226B; //bit 0 Conflict Glyph, bit 1 Death, bit 2 States, bit 3 Nature, bit 4 Energy, bit 5 Balance, bit 7 Disable Soul Reaver
	*/
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.Settings.CreateFromXml("Components/LoKSRR.Settings.xml");
	
	vars.bitCheck = new Func<int, int, bool>((int val, int b) => (val & (1 << b)) != 0);

	vars.finalSplit = 0;
}

init
{
	
	IntPtr Dialogue = vars.Helper.ScanRel(3, "48 89 1d ???????? 48 89 1d ???????? 48 89 1d ???????? e8 ???????? 83 25 ?????????? 48 8d 0d");
	IntPtr SR1States = vars.Helper.ScanRel("sr1.dll", 3, "48 8d 0d ?? ?? ?? ?? e8 ?? ?? ?? ?? 85 c0 75 ?? 83 0b");
	
	vars.Helper["diaState"] = vars.Helper.Make<byte>(Dialogue);
	vars.Helper["diaName"] = vars.Helper.MakeString(Dialogue - 0x34);
	
	vars.Helper["SR1map"] = vars.Helper.MakeString(SR1States);
	vars.Helper["SR1paused"] = vars.Helper.Make<byte>(SR1States + 0x16);
	vars.Helper["SR1Info"] = vars.Helper.Make<int>(SR1States - 0x844);
	
	
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
	vars.Helper.Update();
	vars.Helper.MapPointers();
	
	if(settings["SR1"]){
		if(current.SR1map == "chrono1" && current.SR1Cutscene == 2 && old.SR1Cutscene == 0){
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
		if(current.SR1map != old.SR1map || current.SR1Cutscene != old.SR1Cutscene){
			setting = "Area_" + current.SR1map + "_" + current.SR1Cutscene;
		}
		
		if((current.SR1map == "cathy60" || current.SR1map == "cathy76") && current.SR1Cutscene == 1){
			setting = "glass1";
		}
	
		if((current.SR1map == "cathy59" || current.SR1map == "cathy75") && current.SR1Cutscene == 1){
			setting = "glass2";
		}
	
		if(current.SR1map == "cathy42" && current.SR1Cutscene == 2 && current.SR1x == -812){
			setting = "valve2";
		}
		
		if(current.SR1map == "cathy46" && current.SR1Cutscene == 2 && current.SR1x == -4707){
			setting = "valve3";
		}
		
		if(current.SR1map == "chrono1" && vars.finalSplit == 3 && current.SR1Cutscene == 2 && old.SR1Cutscene == 0){
			return true;
		}
		
		for (int i = 0; i < sizeof(int) * 8; i++){
			if (vars.bitCheck(current.SR1Info, i) && !vars.bitCheck(old.SR1Info, i)){
				setting = "SR1Info_" + i;
			}
		}
	}
	
	if(settings["SR2"]){
		
		if(current.SR2map == "pillars12A" && current.SR2Cutscene == 1 && current.diaName == "SRFNB07C"){
			setting = "EGReturn1";
		}
		
		for (int i = 0; i < sizeof(int) * 8; i++){
			if (vars.bitCheck(current.SR2Info, i) && !vars.bitCheck(old.SR2Info, i)){
				setting = "SR2Info_" + i;
			}
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
