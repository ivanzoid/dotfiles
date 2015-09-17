--------------------------------------------------
---  Copyright 2008-2014, HDRsoft - www.hdrsoft.com   
--------------------------------------------------

return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 1.3, 
	LrToolkitIdentifier = 'com.hdrsoft.photomatix.export.lightroom',
	LrPluginName = 'Export to Photomatix Pro',
	LrPluginInfoUrl = 'http://www.hdrsoft.com/download/lrplugin.html',
	
	VERSION = { display='1.5.2'},

--	LrInitPlugin='InitPhotomatixPlugin.lua',

	LrExportMenuItems = {
		{
			title = "Export to Photomatix Pro...",
			file = 'ExportToPhotomatix.lua',
			enabledWhen = 'photosAvailable',
		},
	},
	
	LrExportServiceProvider = {
		title = "Photomatix",
		file = 'PhotomatixExportServiceProvider.lua',
		builtInPresetsDir = "presets",
	},

}
