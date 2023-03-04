function onCreate()
	addScanlineEffect('game', true)
	addScanlineEffect('hud', true) 
	addBloomEffect('game', 0.004, 0.003)
	addBloomEffect('hud', 0.004, 0.003)
	addGlitchEffect('game', 1, 0.1, 0.2)
	addGrayscaleEffect('hud')
end