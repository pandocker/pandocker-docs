# Templates
## HTML
## LaTeX
### metadata
#### front
#### verbcolored
#### secnumdepth
## Word
### Paragraph and Table styles
### source code token styles \*Tok

> <https://docs.kde.org/stable5/en/applications/katepart/highlight.html#kate-highlight-default-styles>
>
> Default Styles were already explained, as a short summary: Default styles are predefined font and color styles.
>
> General default styles:
>
> - dsNormal, when no special highlighting is required.
> - dsKeyword, built-in language keywords.
> - dsFunction, function calls and definitions.
> - dsVariable, if applicable: variable names (e.g. $someVar in PHP/Perl).
> - dsControlFlow, control flow keywords like if, else, switch, break, return, yield, ...
> - dsOperator, operators like + - * / :: < >
> - dsBuiltIn, built-in functions, classes, and objects.
> - dsExtension, common extensions, such as Qt classes and functions/macros in C++ and Python.
> - dsPreprocessor, preprocessor statements or macro definitions.
> - dsAttribute, annotations such as @override and __declspec(...).
> （後略）

```python
import pprint
import docx

d = docx.Document("ref.docx")
pprint.pprint(sorted([s.name for s in d.styles if "Tok" in s.name ]))
['AnnotationTok',
 'AttributeTok',
 'BaseNTok',
 'BuiltInTok',
 'CharTok',
 'CommentTok',
 'ControlFlowTok',
 'DataTypeTok',
 'DecValTok',
 'ErrorTok',
 'ExtensionTok',
 'FloatTok',
 'FunctionTok',
 'ImportTok',
 'InformationTok',
 'KeywordTok',
 'NormalTok',
 'OperatorTok',
 'OtherTok',
 'PreprocessorTok',
 'RegionMarkerTok',
 'SpecialCharTok',
 'SpecialStringTok',
 'StringTok',
 'VariableTok',
 'VerbatimStringTok',
 'WarningTok']

```

### PostProcess
#### python-docx
