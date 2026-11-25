"
I hold examples for {{gtClass:GtLSPClangdModel}}.

The examples that start a server are live examples: they need the `clangd` executable on the `PATH`. The configuration examples need nothing.
"
Class {
	#name : 'GtLSPClangdModelExamples',
	#superclass : 'Object',
	#category : 'Gt4Clangd-Examples',
	#package : 'Gt4Clangd',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtLSPClangdModelExamples >> configuration [
	<gtExample>
	self assert: GtLSPClangdModel executable isString.
	self assert: GtLSPClangdModel languageType equals: 'cpp'.
	self assert: (GtLSPClangdModel extensions includesSubstring: '*.cpp').
	self assert: (GtLSPClangdModel extensions includesSubstring: '*.h').
	self assert: GtLSPClangdModel styler isNotNil.
	self
		assert: GtLSPClangdModel lspClientClass
		equals: GtLanguageServerProtocolStdioClient.

	^ GtLSPClangdModel
]

{ #category : 'examples' }
GtLSPClangdModelExamples >> diagnostics [
	"I need the clangd executable on the PATH and I start a server. I stop it before I answer."

	<gtExample>
	<return: #GtLSPFileModel>
	| model file directory diagnostics |
	directory := self directory.
	model := GtLSPClangdModel onDirectory: directory.
	file := model fileFor: directory / 'main.cpp'.
	file originalSource: 'int main() { return undeclaredThing; }'.
	file open.
	diagnostics := self waitForDiagnosticsIn: file.
	model shutdown.

	self assert: diagnostics isNotEmpty.
	self
		assert: (diagnostics
				anySatisfy: [ :each | each message includesSubstring: 'undeclaredThing' ]).

	^ file
]

{ #category : 'examples' }
GtLSPClangdModelExamples >> directory [
	<gtExample>
	<return: #FileReference>
	| directory |
	directory := self temporaryDirectory / 'GToolkit4ClangdExamples'.
	directory ensureCreateDirectory.
	directory / 'main.cpp'
		writeStreamDo: [ :stream | stream nextPutAll: self source ].

	self assert: directory exists.
	self assert: (directory / 'main.cpp') exists.
	^ directory
]

{ #category : 'examples' }
GtLSPClangdModelExamples >> extensionsMatchTheSourceFiles [
	<gtExample>
	self
		assert: (self directory / 'main.cpp' gtMatches: GtLSPClangdModel extensions).
	self
		assert: (self directory / 'header.h' gtMatches: GtLSPClangdModel extensions).
	self
		assert: (self directory / 'header.hpp' gtMatches: GtLSPClangdModel extensions).
	self
		assert: (self directory / 'readme.md' gtMatches: GtLSPClangdModel extensions) not.

	^ GtLSPClangdModel extensions
]

{ #category : 'examples' }
GtLSPClangdModelExamples >> model [
	"I need the clangd executable on the PATH and I start a server. I stop it before I answer."

	<gtExample>
	<return: #GtLSPClangdModel>
	| model file directory |
	directory := self directory.
	model := GtLSPClangdModel onDirectory: directory.
	file := model fileFor: directory / 'main.cpp'.

	self assert: model lspClient isRunning.
	self assert: model files size equals: 1.
	self assert: file isNotNil.
	self assert: file filename basename equals: 'main.cpp'.
	self assert: (model fileForUri: file filename uri printString) equals: file.

	model shutdown.
	^ model
]

{ #category : 'examples' }
GtLSPClangdModelExamples >> source [
	<gtExample>
	<return: #String>
	^ 'struct Point { int x; int y; };

int add(int a, int b) { return a + b; }

int main() { Point p; return add(p.x, p.y); }'
]

{ #category : 'examples' }
GtLSPClangdModelExamples >> symbols [
	"I need the clangd executable on the PATH and I start a server. I stop it before I answer."

	<gtExample>
	<return: #Array>
	| model file directory symbols |
	directory := self directory.
	model := GtLSPClangdModel onDirectory: directory.
	file := model fileFor: directory / 'main.cpp'.
	file originalSource: self source.
	file open.
	symbols := self waitForSymbolsIn: model.
	model shutdown.

	self
		assert: (symbols collect: [ :each | each symbolName ]) asSortedCollection asArray
		equals: #('Point' 'add' 'main' 'x' 'y').

	^ symbols
]

{ #category : 'examples' }
GtLSPClangdModelExamples >> temporaryDirectory [
	<gtExample>
	<return: #FileReference>
	^ (Smalltalk os environment at: 'TMPDIR' ifAbsent: [ '/tmp' ]) asFileReference
]

{ #category : 'examples' }
GtLSPClangdModelExamples >> waitForDiagnosticsIn: aFile [
	10
		timesRepeat: [ aFile diagnostics
				ifNotNil: [ :diagnostics | diagnostics ifNotEmpty: [ ^ diagnostics ] ].
			(Delay forSeconds: 1) wait ].
	^ aFile diagnostics ifNil: [ #() ]
]

{ #category : 'examples' }
GtLSPClangdModelExamples >> waitForSymbolsIn: aModel [
	| symbols |
	10
		timesRepeat: [ symbols := aModel allSymbolsStream asAsyncStream toArray wait.
			symbols ifNotEmpty: [ ^ symbols ].
			(Delay forSeconds: 1) wait ].
	^ symbols
]
