let Text/concatMapSep =
        ./Prelude/Text/concatMapSep
      ? https://prelude.dhall-lang.org/Text/concatMapSep

let List/concatMap =
      ./Prelude/List/concatMap ? https://prelude.dhall-lang.org/List/concatMap

let Backend = (./abiSchema.dhall).Backend

let addListTypes
    : List Text → List Text
    = List/concatMap Text Text (λ(t : Text) → [ t, "${t}_list" ])

let typeToDhallType
    : Text → Text
    = λ(t : Text) → "${t} = { ${t} : Text, def : Optional Text }"

let typeToDhallConstructor
    : Backend → Text → Text
    =   λ ( backend
          : Backend
          )
      → λ(t : Text)
      → ''
        ${t} = λ(val : Text) → { ${t} = "${backend.toLiteral "val"}", def = None Text }
        , ${t}ToVoid = λ(x : { ${t} : Text, def : Optional Text }) → { void = "${backend.toVoid
                                                                        "x.${t}"}", def = x.def }
        ''

let typesToDhallConstructors
    : Backend → List Text → Text
    =   λ(backend : Backend)
      → λ(ls : List Text)
      → ''
        let lib = ./default
        
        in { ${Text/concatMapSep
                 ''
                 
                 , ''
                 Text
                 (typeToDhallConstructor backend)
                 (addListTypes ls)} }
        ''

let typesToDhallTypes
    : List Text → Text
    =   λ(ls : List Text)
      → ''
        { ${Text/concatMapSep "\n, " Text typeToDhallType (addListTypes ls)} }
        ''

in  { constructors = typesToDhallConstructors, types = typesToDhallTypes }
