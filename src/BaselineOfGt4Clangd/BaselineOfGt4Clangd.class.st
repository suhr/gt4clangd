Class {
	#name : 'BaselineOfGt4Clangd',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGt4Clangd',
	#package : 'BaselineOfGt4Clangd'
}

{ #category : 'loading' }
BaselineOfGt4Clangd class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'gt4clangd' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : 'baseline' }
BaselineOfGt4Clangd >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'Gt4Clangd'
		]
]
