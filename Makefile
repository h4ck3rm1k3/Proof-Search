ofiles=ProofFuncs.o  ProofParse.o  ProofSearch.o  ProofServer.o  ProofTest.o  ProofTypes.o
files=ProofFuncs.hs  ProofParse.hs  ProofSearch.hs  ProofServer.hs  ProofTest.hs  ProofTypes.hs

test : testFrame2
	./testFrame2 

testFrame2 : testFrame2.hs 
	ghc testFrame2.hs 
clean :
	rm *.o

all : $(ofiles)
	echo all

%.o: %.hs
	ghc $<

lint : 
	hlint *.hs

lint2 : 
	hlint ProofTest.hs

scan :
	~/.cabal/bin/scan *.hs
