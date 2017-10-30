var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Manual",
    "title": "Manual",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#MathOptFormat.jl-1",
    "page": "Manual",
    "title": "MathOptFormat.jl",
    "category": "section",
    "text": "The file format is under active development. No backward compatibility yet!"
},

{
    "location": "index.html#Background-1",
    "page": "Manual",
    "title": "Background",
    "category": "section",
    "text": "In order to use an optimization solver, it is necessary to communicate a model instance to the solver.[1] Many different instance formats have been proposed over the years, but only a few (such as MPS) have become the industry standard.Each format is a product of its time in history, and the problem class it tried to address. For example, we retain the rigid input format of the MPS file that was designed for 1960's punchcards and inspired by the column-row input notation of FORTRAN despite the (near) obsolescence of these technologies.[2] Although it has since been  extended to problem classes such as nonlinear and stochastic linear programming, MPS was not designed with extensibility in mind. This has led some authors (such as [3]) to conclude that developing a new format is easier than extending the existing MPS format.The LP file-format also dates back to the work of Orchard-Hays who attempted to correct the ''mistakes'' of the MPS file-format by creating a human-readable, row-oriented format for mathematicians.[2] However, due to its age, there is no longer a single standard for the LP file-format. This has led to subtle differences between implementations in different readers that hampers the usefulness of the format as a format for interchange. Much like the MPS file, it is also limited in the types of problems it can represent and was not designed for extensibility.In constrast to the LP file, the .NL file explicitly aims for machine-readability at the expense of human-readability.[5] It is also considerably more flexible in the problem classes it can represent (in particular, arbitrary nonlinear functions are supported). However, once again, the format is not extensible to new problem formats, and lacks support for conic problems.More recently, considerable work has been put into developing the OSiL format.[4] In developing OSiL, Fourer et al. idenfied many of the challenges and limitations of previous formats and attempted to overcome them. In particular, they choose to use XML as the basis for their format. This removed the burden of writing custom readers and writers for each programming language that wished to interface with optimization software and allowed more focus on the underlying data-structures. XML is also human-readable and can be rigidly specified with a schema to prevent the profilferation of similar, but incompatible versions. The XML approach also allows for easy extensibility and can support multiple problem classes including nonlinear, stochastic, and conic.However, despite the many apparent advantages of the OSiL format, we believe it has enough short-comings to justify the development of a new instance format. Two of the main reasons are the verbosity of the XML format, and the lack of a strong, extensible standard form. We now address each of these two points and give our solutions."
},

{
    "location": "index.html#JavaScript-Object-Notation-(JSON)-1",
    "page": "Manual",
    "title": "JavaScript Object Notation (JSON)",
    "category": "section",
    "text": "https://www.json.org/xml.html"
},

{
    "location": "index.html#The-MathOptInterface-Standard-Form-1",
    "page": "Manual",
    "title": "The MathOptInterface Standard Form",
    "category": "section",
    "text": "http://www.juliaopt.org/MathOptInterface.jl/latest/The standard form problem is:beginalign\n     min_x in mathbbR^n  f_0(x)\n    \n     textst  f_i(x)  in mathcalS_i  i = 1 ldots m\nendalign"
},

{
    "location": "index.html#Project-Goals-1",
    "page": "Manual",
    "title": "Project Goals",
    "category": "section",
    "text": "With this understanding of the history and evolution of different file-formats, the following goals guided our development of the MathOptFormat:Human-readable: the format should be able to be read and edited by a  human.\nMachine-readable: the format should be able to be read by a variety of different programming languages without needing to write custom parsers in each language.\nStandardized: the format should conform to a well described  ''standard-form'' that is unambiguous.\nExtensible: the format should be able to be easily extended to incorporate  new problem-classes as they arise."
},

{
    "location": "index.html#The-format-1",
    "page": "Manual",
    "title": "The format",
    "category": "section",
    "text": "We choose the \"function-in-set\" standard form approach of MathOptInterface.jl.This is a high-level standard form that enables a high degree of flexibility, yet allows a detailed description of the individual components.This allows new functions and sets to be added in a compatible way.The choice of a markup language (JSON) also allows arbitrary fields to be added to extend the format."
},

{
    "location": "index.html#References-1",
    "page": "Manual",
    "title": "References",
    "category": "section",
    "text": "[1]: Gassmann, H., Ma, J., Martin, K. (2010). Instance Formats for Mathematical Optimization Models. In Wiley Encyclopedia of Operations Research and Management Science.[2]: Orchard-Hays, W. (1984). History of Mathematical Programming Systems. Annals of the History of Computing, 6(3).[3]: Friberg, H. (2014). The conic benchmark format: version 1 - technical reference manual (Technical Report E-0047). Department of Wind Energy, Technical University of Denmark.[4]: Fourer, R., Jun M., Kipp M. (2010). OSiL: An Instance Language for Optimization. Computational Optimization and Applications 45(1): 181–203.[5]: Gay, D. (1995). Writing .nl Files (SAND2005-7907P). Sandia National Laboratories, Albuquerque, NM."
},

]}
