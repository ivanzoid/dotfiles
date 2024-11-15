let hostname = substitute(system('hostname'), '\n', '', '')
if hostname == 'IvanMacPro.local'
	set guifont=Fira\ Code\ Regular:h20
elseif hostname == 'IvanBookPro.local'
	set guifont=Fira\ Code\ Regular:h16
else
	set guifont=Fira\ Code\ Regular:h16
endif
set guicursor+=a:blinkwait0		" no cursor flashing!
set vb t_vb=					" no beeping and no flashing!
set guioptions=aeigrtb			" default is emgrLtT
