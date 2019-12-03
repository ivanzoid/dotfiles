let hostname = substitute(system('hostname'), '\n', '', '')
if hostname == 'IvanMac.local' || hostname == 'IvanBookPro.local' || hostname == 'IvanMacPro'
	set guifont=Fira\ Code\ Regular:h20
	"set guifont=Go\ Mono:h18
else
	set guifont=Fira\ Code\ Regular:h16
	"set guifont=Go\ Mono:h16
endif
set guicursor+=a:blinkwait0		" no cursor flashing!
set vb t_vb=					" no beeping and no flashing!
set guioptions=aeigrtb			" default is emgrLtT
