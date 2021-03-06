(* ::Package:: *)

BeginPackage["GeoMeTry`"];


GeoMeTry::usage = "Let's try~";
If[Not@ValueQ[JacobiMatrix::usage], JacobiMatrix::usage =
"JacobiMatrix[{f1, f2, ...}, {\!\(\*SubscriptBox[\(\[Xi]\), \(1\)]\), \!\(\*SubscriptBox[\(\[Xi]\), \(2\)]\), ...}] returns the Jacobi matrix \
of the vactor function."];

If[Not@ValueQ[MinkowskiMetric::usage], MinkowskiMetric::usage =
"MinkowskiMetric[dim, sig : -1] gives the metric of dim dimensional \
Minkowski space with signatue sig."];

If[Not@ValueQ[Metric::usage], Metric::usage =
"Metric[trans, coor] gives the metric under coor coodinates."];

If[Not@ValueQ[ChristoffelSymbol::usage], ChristoffelSymbol::usage =
"ChristoffelSymbol[g, {\!\(\*SubscriptBox[\(\[Xi]\), \(1\)]\), \!\(\*SubscriptBox[\(\[Xi]\), \(2\)]\), ...}] return an \
n-by-n-by-n table whose component [[\[Lambda], \[Alpha], \[Beta]]] is the Christoffel Symbol \!\(\*SubscriptBox[SuperscriptBox[\(\[CapitalGamma]\), \(\[Lambda]\)], \(\[Alpha]\[Beta]\)]\) under \[Xi] space with metric g."];

If[Not@ValueQ[RiemannTensor::usage], RiemannTensor::usage =
"RiemannTensor[conn, coor]"];

If[Not@ValueQ[RicciTensor::usage], RicciTensor::usage =
"RicciTensor[riemann_tensor]"];

If[Not@ValueQ[RicciScalar::usage], RicciScalar::usage =
"RicciScalar[metric, ricci_tensor]"];

If[Not@ValueQ[EinsteinTensor::usage], EinsteinTensor::usage =
"EinsteinTensor[metric, ricci_tensor]"];


If[Not@ValueQ[GmtShow::usage], GmtShow::usage =
"GmtShow[tensor]"];

If[Not@ValueQ[GmtAll::usage], GmtAll::usage =
"GmtAll[symbol, metric, {x1, x2, ...}]"];


If[Not@ValueQ[InducedFrom::usage], InducedFrom::usage =
"InducedFrom is an option for metric related functions to configure \
the origional metric of transformations. The default value is Euclidean."];
If[Not@ValueQ[Euclidean::usage], Euclidean::usage =
"If InducedFrom is set to Euclidean, functions will use identity \
matrix as origional metric for transformations."];
If[Not@ValueQ[MinkowskiPlus::usage], MinkowskiPlus::usage =
"If InducedFrom is set to MinkowskiPlus, functions will use Minkowski \
metric with signature (+, -, ...) as origional metric for transformations."];
If[Not@ValueQ[MinkowskiMinus::usage], MinkowskiMinus::usage =
"If InducedFrom is set to MinkowskiMinus, functions will use Minkowski \
metric with signature (-, +, ...) as origional metric for transformations."];

GeoMeTry::opts = "`1`";


Begin["`Private`"];


Options[GmtTransformOptions]={InducedFrom->Euclidean};


GmtMetricTypes={Euclidean,MinkowskiPlus,MinkowskiMinus};


GmtGetMetric=Switch[#2,
	Euclidean,IdentityMatrix[#1],
	MinkowskiPlus,MinkowskiMetric[#1,+1],
	MinkowskiMinus,MinkowskiMetric[#1],
	MinkowskiMetric,Message[GeoMeTry::opts,"'MinkowskiMetric' is a function name, you may use 'MinkowskiMinus' or 'MinkowskiPlus' instead."],
	_,#2]&;
RankCheck[rank_Integer]:=Function[{tensor},Equal@@Dimensions@tensor&&ArrayDepth[tensor]==rank];


JacobiMatrix=Simplify[Table[D[o,i],{o,#1},{i,#2}]]&;


MinkowskiMetric[n_,sig_:-1] :=
	DiagonalMatrix[{Sign[sig]}~Join~Table[-Sign[sig],{i,n-1}]];


Metric[trans_,coor_,OptionsPattern[GmtTransformOptions]]:=Simplify[Check[
	Transpose[#].GmtGetMetric[Length[trans],OptionValue[InducedFrom]].
	#&[JacobiMatrix[trans,coor]],Abort[]]];


ChristoffelSingle[g_,x_List,u_Integer,m_Integer,n_Integer]/;
	MatrixQ[g]&&Dimensions[g]==Function[a,{a,a}][Dimensions[x][[1]]]:=
		Simplify[1/2 Inverse[g][[u]].(D[g[[m]],x[[n]]]+D[g[[n]],x[[m]]]-Grad[g[[m,n]],x])];
ChristoffelSingle[trans_,coor_,u_,m_,n_,OptionsPattern[GmtTransformOptions]]/;
	AllTrue[VectorQ,{trans,coor}]&&Length[trans]==Length[coor]:=
	ChristoffelSingle[Metric[trans,coor,InducedFrom->OptionValue[InducedFrom]],coor,u,m,n];


ChristoffelSymbol[trans_,coor_,opts__:{}]:=Simplify[
	Table[ChristoffelSingle@@{trans,coor,u,m,n}~Join~Flatten[{opts}],{u,Length[coor]},{m,Length[coor]},{n,Length[coor]}]];


RiemannTensor[conn_?(RankCheck[3]),coor_]/;Length[conn]==Length[coor]:=Simplify[Table[
	D[conn[[r,n,s]],coor[[m]]]-D[conn[[r,m,s]],coor[[n]]]
		+Sum[conn[[r,m,l]]conn[[l,n,s]]-conn[[r,n,l]]conn[[l,m,s]],{l,Length[coor]}],
	{r,Length[coor]},{s,Length[coor]},{m,Length[coor]},{n,Length[coor]}]];


RicciTensor[rt_?(RankCheck[4])]:=Simplify[Sum[rt[[i,All,i,All]],{i,Length[rt]}]];


RicciScalar[g_?(RankCheck[2]),rt_?(RankCheck[2])]:=Simplify[Tr[Inverse[g].rt]];


EinsteinTensor[g_?(RankCheck[2]),rt_?(RankCheck[2])]:=Simplify[rt-RicciScalar[g,rt]g/2];


(* Convenient Functions *)
GmtShow[tensor_?(ArrayDepth[#]<=2&)]:=MatrixForm[tensor];
GmtShow[tensor_?(RankCheck[3])]:=TableForm[Map[MatrixForm,tensor],TableHeadings->{Array[
	ToExpression[OverscriptBox["\!\(\*SubscriptBox[\(\[CapitalGamma]\), \(\[Alpha]\[Beta]\)]\)",ToString[#]]]&,Length[tensor]]},TableSpacing->5];
GmtShow[tensor_?(RankCheck[4])]:=TableForm[Map[MatrixForm,tensor,{2}],TableAlignments->Center,TableSpacing->5];


GmtGiveSymbol[s__]:=With[{str=StringJoin@@(ToString/@{s})},Clear[str];Print["** Declearing: ",str];Symbol[str]];
GmtAll[name_Symbol,g_,x_]:=GmtAll[SymbolName[name],g,x];
GmtAll[name_String,g_?(RankCheck[2]),x_?VectorQ]:=With[{
	conn=GmtGiveSymbol[name,"Christoffel"],
	rie=GmtGiveSymbol[name,"RiemannTensor"],
	ric=GmtGiveSymbol[name,"RicciTensor"],
	r=GmtGiveSymbol[name,"RicciScalar"]},

	conn=ChristoffelSymbol[g,x];
	rie=RiemannTensor[conn,x];
	ric=RicciTensor[rie];
	r=RicciScalar[g,ric];
];


End[];


EndPackage[];
