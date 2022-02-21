#version 330 core

uniform float iTime;
uniform float iTimeDelta;
uniform int   iFrame;
uniform vec3  iResolution;
uniform vec3  iMouse;
#define fragCoord gl_FragCoord.xy

out vec4 fragColor;


#define N_HIDDEN 12

vec4 bufA[N_HIDDEN/4];
vec4 bufB[N_HIDDEN/2];


vec4 cppn_fn(vec2 coordinate, float in0, float in1, float in2, float in3) {
    vec4 tmp;
    bufB[0] = vec4(coordinate.x, coordinate.y, 0., 0.);
	bufA[0] = vec4(0.102494344,-0.3149098,0.0889423,-0.08406228) + mat4(vec4(1.1473791599273682,0.917512834072113,0.3619094789028168,0.43293875455856323),vec4(-1.0770035982131958,-0.10332044214010239,-0.7286443114280701,-0.8746699094772339),vec4(0.0,0.0,0.0,0.0),vec4(0.0,0.0,0.0,0.0)) * bufB[0];
	bufA[1] = vec4(-0.19154887,0.039072312,-0.10263007,0.0056149545) + mat4(vec4(-0.4313870668411255,0.2697005271911621,-0.7440120577812195,-1.5243027210235596),vec4(0.7961501479148865,-0.6391657590866089,-0.2543102204799652,1.3714649677276611),vec4(0.0,0.0,0.0,0.0),vec4(0.0,0.0,0.0,0.0)) * bufB[0];
	bufA[2] = vec4(-0.06744594,-0.037041266,0.58247536,0.21809055) + mat4(vec4(-0.6250119209289551,0.8330039978027344,-0.14713536202907562,-0.1770920604467392),vec4(-0.18396662175655365,0.15434005856513977,-1.3491480350494385,0.4988882541656494),vec4(0.0,0.0,0.0,0.0),vec4(0.0,0.0,0.0,0.0)) * bufB[0];
	tmp = atan(bufA[0]);
	bufB[0] = tmp/0.67;
	bufB[3] = (tmp*tmp) / (iMouse[1] / 2000. - sin(iTime * 0.1)) ;
	tmp = atan(bufA[1]);
	bufB[1] = tmp/0.67;
	bufB[4] = (tmp*tmp) / (iMouse[0] / 2000. + cos(iTime * 0.1));
	tmp = atan(bufA[2]);
	bufB[2] = tmp/0.67;
	bufB[5] = (tmp*tmp) / (iMouse[0] / 2. + cos(iTime * 0.1)) ;
	bufA[0] = vec4(-0.022725677,-0.12785904,0.067601785,-0.1786982) + mat4(vec4(-0.15866843,-0.0017020032,-0.10624226,0.08443136),vec4(0.24148706,0.12337165,-0.17282465,0.07874396),vec4(-0.40642366,0.094567835,0.0646437,0.18558556),vec4(-0.37642264,0.24098131,-0.29809853,0.39744455)) * bufB[0] + mat4(vec4(0.006150027,0.052358087,-0.07348546,-0.04620363),vec4(-0.16825396,-0.19316062,-0.30342934,0.11345573),vec4(-0.05103772,-0.22854564,-0.35815427,-0.34710243),vec4(0.3242196,-0.3957056,0.36199927,0.1936316)) * bufB[1] + mat4(vec4(-0.095162235,0.36450404,-0.22744744,0.16701584),vec4(-0.34848046,-0.124467395,0.066819295,0.07080892),vec4(-0.12415395,-0.18711752,-0.053525858,-0.14807215),vec4(0.2349349,-0.004146436,0.4059195,-0.6621611)) * bufB[2] + mat4(vec4(-0.8277543,0.27211168,-0.19687341,-0.2325237),vec4(0.4728746,-0.37685853,0.1976747,0.19855891),vec4(-0.39925107,0.44354814,-0.29689488,0.42856252),vec4(-0.5909986,-0.15851308,-0.031075874,0.0030396995)) * bufB[3] + mat4(vec4(-0.43461955,0.76623064,0.10030234,0.43764496),vec4(-0.4964623,0.6027754,-0.1621302,0.4295603),vec4(0.3178323,-0.5742554,-0.01629593,-0.56272584),vec4(-0.32453895,0.4553503,-0.07128243,-0.25331715)) * bufB[4] + mat4(vec4(0.25975165,-0.3933986,0.02121493,-0.13996424),vec4(0.62955433,-0.088892214,0.15471002,0.19881186),vec4(0.20648274,-0.13041203,0.37989858,0.88699234),vec4(-0.6085314,-0.21943341,0.019307334,0.35044464)) * bufB[5];
	bufA[1] = vec4(-0.11005945,-0.16215608,-0.2860685,0.42052174) + mat4(vec4(1.140972,0.042846642,-0.08323872,0.27196366),vec4(0.28680894,0.13012351,0.07962783,-0.05174748),vec4(0.15521935,0.27595368,-0.29510018,0.009269187),vec4(0.31032568,-0.32126343,0.024398934,0.28833473)) * bufB[0] + mat4(vec4(-0.33146775,0.12263903,-0.11719579,-0.33095726),vec4(0.3000606,-0.06865517,-0.39891243,-0.020390337),vec4(0.062397495,0.3027208,0.030492542,-0.73543227),vec4(-0.5176109,-0.35824224,0.22326073,-0.06672132)) * bufB[1] + mat4(vec4(-0.2671369,0.27659166,-0.066999614,-0.041016966),vec4(0.032092284,0.013130778,-0.12282955,0.26701826),vec4(0.124337666,-0.1837933,-0.34601402,0.13187033),vec4(0.07471488,0.049896605,0.23096617,0.46766686)) * bufB[2] + mat4(vec4(0.04613479,-0.20156668,0.10992843,-0.21159415),vec4(-0.59783936,0.02389471,0.51146805,-0.09515047),vec4(0.2621687,0.33345369,-0.2585786,-0.2946997),vec4(0.13540758,-0.05325895,0.33425573,-0.2713386)) * bufB[3] + mat4(vec4(0.344948,0.7994166,0.021299517,-0.08552964),vec4(0.34926042,0.4360638,-0.33172187,-0.54888344),vec4(0.007140842,0.06423914,0.12257519,0.030679772),vec4(0.032083437,0.07881584,-0.12281115,-0.2500298)) * bufB[4] + mat4(vec4(-0.2467862,-0.2103137,0.14627492,0.72159),vec4(-0.3978151,-0.12814447,0.46904036,0.37411827),vec4(0.08602959,-0.10627407,0.23534487,0.1606414),vec4(0.014149565,0.031527795,-0.4000729,-0.57322574)) * bufB[5];
	bufA[2] = vec4(0.11252319,0.050059497,-0.15493545,-0.10618238) + mat4(vec4(-0.0139367385,0.13224158,0.060087904,0.3764976),vec4(0.52614367,0.053057745,-0.07411005,0.3602826),vec4(-0.09141114,0.047984153,-0.4063019,0.15959878),vec4(-0.24306014,0.36736766,0.2816425,0.33604708)) * bufB[0] + mat4(vec4(-0.17742845,0.20678905,0.1388638,0.041700784),vec4(-0.5054578,-0.043476444,0.23766263,0.3193988),vec4(-0.23454075,0.25580156,0.053867783,0.15614475),vec4(-0.0067268927,-0.2502053,-0.14891438,-0.3715893)) * bufB[1] + mat4(vec4(-0.15641835,0.09222974,0.14984371,-0.12004761),vec4(0.009601281,-0.012543719,-0.46508747,0.34722933),vec4(-0.07665625,0.20956996,-0.13098899,-0.00012878329),vec4(0.607429,-0.18217735,0.0024376367,-0.3614427)) * bufB[2] + mat4(vec4(-0.54478353,0.21366404,0.14872125,0.031317186),vec4(0.07195057,0.19251058,-0.37935328,-0.52749),vec4(0.17059901,-0.23699392,0.19837996,0.32681787),vec4(0.5582123,0.27163684,0.18101668,0.6746835)) * bufB[3] + mat4(vec4(0.16172904,-0.40386227,0.54160726,0.12950169),vec4(0.12832806,0.027426135,0.3380297,0.23594113),vec4(-0.5718847,0.070739135,-0.5558023,-0.088432394),vec4(-0.37768972,-0.1472861,0.39567947,-0.25489992)) * bufB[4] + mat4(vec4(-0.1947735,0.07175936,-0.013799782,-0.09297364),vec4(0.0832247,-0.06616701,-0.10768768,-0.42004693),vec4(-0.045834363,0.2285234,-0.15082465,0.16031589),vec4(0.15329438,-0.54191613,0.38852856,-0.07420482)) * bufB[5];
	tmp = atan(bufA[0]);
	bufB[0] = tmp/0.67;
	bufB[3] = (tmp*tmp) / (iMouse[0] / 2000. + cos(iTime * 0.1)) ;
	tmp = atan(bufA[1]);
	bufB[1] = tmp/0.67;
	bufB[4] = (tmp*tmp) / (iMouse[0] / 2. + cos(iTime * 0.1) * 1000.) ;
	tmp = atan(bufA[2]);
	bufB[2] = tmp/0.00017;
	bufB[5] = (tmp*tmp) / (iMouse[0] / 2. + cos(iTime * 0.1) * 1000.) ;
	bufA[0] = vec4(0.06347933,0.1612854,0.19830905,-0.19739431) + mat4(vec4(-0.045668826,-0.064619444,0.7846834,0.3412297),vec4(-0.086859904,0.30597797,-0.31021985,0.17199573),vec4(-0.205019,-0.4335874,0.32475796,0.36061805),vec4(-0.24554123,0.048643183,0.49432454,-0.059098117)) * bufB[0] + mat4(vec4(0.4751836,0.72574294,-0.24269576,-0.71770555),vec4(-0.086143084,0.04304948,-0.17447732,0.029122032),vec4(-0.13177453,0.024686681,-0.20643896,-0.12353481),vec4(0.39642146,0.9019975,0.30304202,-0.4365204)) * bufB[1] + mat4(vec4(-0.17064893,-0.29427406,0.29778546,0.30750158),vec4(-0.08069512,0.14789018,0.08628571,0.02087178),vec4(-0.02627688,-0.35136414,-0.51401734,0.028279714),vec4(-0.0039906767,0.32455355,-0.46454477,-0.30168983)) * bufB[2] + mat4(vec4(0.10995319,-0.34148207,-0.2627336,0.63228154),vec4(-0.2518018,0.07631582,0.5602692,-0.02050484),vec4(-0.46116304,-0.32934743,0.42501134,0.5594866),vec4(0.37455654,0.35638422,-0.091756225,-0.3931594)) * bufB[3] + mat4(vec4(0.15477678,0.15843254,-0.99112236,0.07851654),vec4(-0.2629532,-0.32569164,0.069722936,0.18718007),vec4(0.20048165,-0.39193678,0.38479644,0.42006215),vec4(-0.07321948,-0.090297475,-0.1586782,-0.24511369)) * bufB[4] + mat4(vec4(0.3512004,-0.2783627,0.3195087,0.20522293),vec4(0.19734944,0.23291095,0.25053683,0.06375094),vec4(-0.4839323,-0.48978326,0.30843383,-0.049317747),vec4(-0.12370474,-0.23608193,-0.330141,0.55754596)) * bufB[5];
	bufA[1] = vec4(0.37417954,0.047155242,-0.46701705,0.08693643) + mat4(vec4(0.5399446,0.61172366,-0.4156259,-0.43418682),vec4(-0.57787454,-0.18989712,0.23022255,-0.013156356),vec4(0.020598646,0.38512963,-0.29040217,-0.19312504),vec4(0.10914084,0.27611247,0.035677344,-0.65140265)) * bufB[0] + mat4(vec4(-0.0019135558,-0.42581996,-0.16223507,0.5999634),vec4(-0.19923085,-0.11021978,-0.056887925,0.13113227),vec4(0.30461797,-0.32200494,0.17810053,0.016854594),vec4(0.7279897,0.2618202,-0.90671664,-0.1747922)) * bufB[1] + mat4(vec4(-0.37294063,0.31666127,0.5198492,-0.15310118),vec4(-0.0013977436,-0.020357814,0.110533044,-0.080724776),vec4(-0.77488726,-0.49681127,0.09652701,0.38309702),vec4(-0.26938203,-0.40088636,0.21800175,-0.14407155)) * bufB[2] + mat4(vec4(-0.13934302,-0.29814103,0.09915037,-0.27325016),vec4(0.10180718,0.61114883,-0.023113828,-1.1485668),vec4(-0.040888365,0.036651347,0.09381472,-0.18109809),vec4(-0.18992867,-0.22143385,0.8432306,0.22045662)) * bufB[3] + mat4(vec4(0.16226712,-0.7333021,0.0758144,0.5907945),vec4(-0.07683443,0.56431687,0.3524583,-0.03337921),vec4(0.23871389,0.28256166,-0.7298879,-0.30360952),vec4(-0.34301555,-0.28118518,-0.43773583,0.07229201)) * bufB[4] + mat4(vec4(0.29310104,0.5629743,-0.029153556,0.21643211),vec4(-0.19977422,0.36416233,-0.17659925,-0.4437099),vec4(-0.4400485,0.16025025,-0.20645909,-0.24711363),vec4(0.13231798,0.07309352,-0.42538086,0.26351887)) * bufB[5];
	bufA[2] = vec4(-0.2712942,-0.29896623,0.31517306,-0.093013175) + mat4(vec4(1.223944,-0.3658218,0.3219709,-0.014604855),vec4(-0.6657022,0.6038405,-0.27225438,-0.10032703),vec4(0.20058393,0.12633212,0.3271876,-0.10984932),vec4(-0.20862058,0.0076043713,-0.03220099,-0.0020434642)) * bufB[0] + mat4(vec4(-0.5203198,0.1633029,0.11762935,0.18600368),vec4(-0.41859502,0.2777773,-0.08738997,0.035295088),vec4(0.18913743,0.14343902,0.004859038,-0.07212969),vec4(-0.020642815,-0.6160782,0.49625218,0.57012504)) * bufB[1] + mat4(vec4(-0.10758107,-0.017402373,-0.08157056,-0.2501992),vec4(-0.21661945,-0.08957064,-0.11353558,0.3905056),vec4(-0.94417286,0.5128097,-0.7874086,-0.051024847),vec4(-0.23321709,-0.054822367,-0.082260914,0.10680084)) * bufB[2] + mat4(vec4(-0.0022457705,-0.07225652,-0.3586538,0.43740377),vec4(0.3355094,-0.2813889,0.09732224,-0.27368993),vec4(0.05686852,-0.0891114,0.2911353,-0.12542279),vec4(-0.49646282,-0.28926378,0.24992238,-0.17121428)) * bufB[3] + mat4(vec4(-0.5338403,0.12760584,0.040012024,0.044568915),vec4(-0.1908641,-0.02976791,-0.06841452,0.12142611),vec4(0.56918883,-0.027428608,0.21422353,-0.38472137),vec4(-0.31912565,0.46659365,0.22852217,-0.023818875)) * bufB[4] + mat4(vec4(0.14933504,-0.705254,0.211169,0.07068923),vec4(-0.007858947,0.14319351,-0.36016887,0.13738787),vec4(-0.15513018,0.7104456,0.064691246,0.36760435),vec4(-0.173803,-0.22940974,-0.47465748,0.07304159)) * bufB[5];
	tmp = atan(bufA[0]);
	bufB[0] = tmp/0.67;
	bufB[3] = (tmp*tmp) / (iMouse[0] / 2. + cos(iTime * 0.1) * 1000.) ;
	tmp = atan(bufA[1]);
	bufB[1] = tmp/0.67;
	bufB[4] = (tmp*tmp) / (iMouse[0] / 2. + cos(iTime * 0.1) * 1000.) ;
	tmp = atan(bufA[2]);
	bufB[2] = tmp/0.67;
	bufB[5] = (tmp*tmp) / (iMouse[0] / 2. + cos(iTime * 0.1) * 1000.) ;
	bufA[0] = vec4(0.06628160923719406,0.1676013171672821,-0.09024585038423538,0.0) + mat4(vec4(0.19095468521118164,0.09810858219861984,0.12410550564527512,0.0),vec4(0.1366337388753891,0.19074495136737823,0.05801703408360481,0.0),vec4(0.16732381284236908,-0.0518123097717762,-0.39728665351867676,0.0),vec4(-0.06508978456258774,-0.1920517534017563,-0.03606376424431801,0.0)) * bufB[0] + mat4(vec4(0.11388109624385834,0.14725792407989502,0.004177249036729336,0.0),vec4(0.03375318646430969,-0.1357901245355606,-0.401125431060791,0.0),vec4(-0.23200896382331848,-0.37413761019706726,-0.08679073303937912,0.0),vec4(0.02121201530098915,0.07964148372411728,0.48142123222351074,0.0)) * bufB[1] + mat4(vec4(0.09451346099376678,0.019663002341985703,-0.19825531542301178,0.0),vec4(-0.1175503209233284,0.051474429666996,0.18779027462005615,0.0),vec4(0.2141251116991043,0.036118023097515106,-0.03609921410679817,0.0),vec4(0.16020317375659943,0.019449396058917046,-0.059026505798101425,0.0)) * bufB[2] + mat4(vec4(0.05964646860957146,0.10610362887382507,-0.005862472113221884,0.0),vec4(0.03946983441710472,0.15989886224269867,-0.040037013590335846,0.0),vec4(-0.12626393139362335,0.136710062623024,0.21594607830047607,0.0),vec4(-0.008167805150151253,0.15512491762638092,-0.08165955543518066,0.0)) * bufB[3] + mat4(vec4(-0.0456172339618206,-0.20285142958164215,-0.3590785562992096,0.0),vec4(-0.04337179660797119,-0.0022717348765581846,0.37243831157684326,0.0),vec4(0.02868317998945713,-0.07511451095342636,-0.12632034718990326,0.0),vec4(-0.067044697701931,-0.16469092667102814,0.14049416780471802,0.0)) * bufB[4] + mat4(vec4(-0.11885490268468857,-0.30989575386047363,-0.10004056990146637,0.0),vec4(-0.05331268161535263,-0.07177876681089401,-0.2918018400669098,0.0),vec4(-0.04697512835264206,0.029311807826161385,-0.1849474012851715,0.0),vec4(0.05290777236223221,0.03825151547789574,0.20864365994930267,0.0)) * bufB[5] + in0;
	return vec4((1. / (1. + exp(-bufA[0]))).xyz, 1.0);
}

void main() {
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    vec2 mouseNorm = (iMouse.xy / iResolution.xy) - vec2(0.5, 0.5);


    uv.x *= iResolution.x / iResolution.y;
    uv.x -= ((iResolution.x / iResolution.y) - 1.) /2.;


    // Shifted to the form expected by the CPPN
    uv = vec2(1., -1.) * 1. * (uv - vec2(0.5, 0.5));
    // Output to screen
    fragColor = cppn_fn(uv, sin(iTime), sin(2.*iTime) * 2., sin(3.*iTime) * 2., sin(4.*iTime));
}
        