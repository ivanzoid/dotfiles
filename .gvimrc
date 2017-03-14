let hostname = substitute(system('hostname'), '\n', '', '')
if hostname == 'IvanMac.local' || hostname == 'IvanBookPro.local'
	set guifont=Go\ Mono:h18
else
	set guifont=Go\ Mono:h16
endif
set guicursor+=a:blinkwait0		" no cursor flashing!
set vb t_vb=					" no beeping and no flashing!
set guioptions=aeigrtb			" default is emgrLtT
