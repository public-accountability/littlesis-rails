# frozen_string_literal: true

module PersonConstants
  # Map between attribute as symbol to string text for presentation
  # Person::DISPLAY_ATTRIBUTES[:name_last] -> 'Last Name:*'
  DISPLAY_ATTRIBUTES = {
    en: {
      name_first: 'First Name',
      name_last: 'Last Name',
      name_middle: 'Middle Name',
      name_prefix: 'Prefix',
      name_suffix: 'Suffix',
      name_nick: 'Nickname',
      birthplace: 'Birthplace'
    },
    es: {
      name_first: 'Primer nombre',
      name_last: 'Apellido',
      name_middle: 'Segundo nombre',
      name_prefix: 'Prefijo',
      name_suffix: 'Sufijo',
      name_nick: 'Apodo',
      birthplace: 'Lugar de nacimiento'
    },
    fr: {
      name_first: 'Prénom',
      name_last: 'Nom de famille',
      name_middle: 'Deuxième nom',
      name_prefix: 'Préfixe',
      name_suffix: 'Suffixe',
      name_nick: 'Surnom',
      birthplace: 'Lieu de naissance'
    }
  }.freeze

  SHORT_FIRST_NAMES = {
    'ab' => 'abner',
    'abbie' => 'abigail',
    'abby' => 'abigail',
    'abe' => ['abel','abraham', 'abram'],
    'acer' => 'acera',
    'ada' => 'adeline',
    'addie' => 'adelaide',
    'ag' => 'agatha',
    'aggy' => 'agatha',
    'agnes' => ['agatha','inez'],
    'al' => ['albert','alexander','alfred'],
    'alec' => 'alexander',
    'alex' => 'alexander',
    'alf' => 'alfred',
    'amy' => ['amanda','amelia'],
    'andy' => ['andreas', 'andrew'],
    'angie' => 'angeline',
    'ann' => ['deanne','hannah','susanna'],
    'anna' => ['hannah', 'susanna' ],
    'anne' => ['hannah','susanna'],
    'annette' => ['ann','anna'],
    'annie' => ['ann','anna','hannah','susanna'],
    'appy' => 'apollonia',
    'archy' => 'archibald',
    'arnie' => 'arnold',
    'arny' => 'arnold',
    'art' => ['artemis','arthur'],
    'arty' => 'arthur',
    'bab' => 'barbara',
    'babs' => 'barbara',
    'barb' => 'barbara',
    'barney' => 'barnabas',
    'bart' => 'bartholomew',
    'barty' => 'bartholomew',
    'bass' => 'sebastian',
    'bea' => ['beatta','beatrice'],
    'beattie' => 'beatrice',
    'becky' => 'rebecca',
    'bella' => ['arabella','belinda','elizabeth','isabel','isabella','mirabel'],
    'belle' => ['mabel','sybil'],
    'ben' => ['benedict','benjamin'],
    'bert' => ['delbert','egbert'],
    'bertie' => ['albert','gilbert'],
    'bess' => 'elizabeth',
    'bessie' => 'elizabeth',
    'beth' => 'elizabeth',
    'beto' => 'alberto',
    'betsy' => 'elizabeth',
    'betty' => 'elizabeth',
    'bev' => 'beverly',
    'bill' => 'william',
    'bob' => 'robert',
    'burt' => 'egbert',
    'cal' => ['caleb', 'calvin'],
    'carol' => 'caroline',
    'cassie' => 'cassandra',
    'cathy' => 'catherine',
    'caty' => 'catherine',
    'cecily' => 'cecilia',
    'charlie' => 'charles',
    'chet' => 'chester',
    'chris' => ['christian','christine', 'crystal'],
    'chuck' => 'charles',
    'cindy' => ['cynthia','lucinda'],
    'cissy' => ['cecilia', 'clarissa'],
    'claus' => 'nicholas',
    'cleat' => 'cleatus',
    'clem' => ['clement', 'clementine'],
    'cliff' => ['clifford', 'clifton'],
    'clo' => 'chloe',
    'connie' => ['constance','cornelia'],
    'conny' => 'cornelia',
    'cora' => 'corinne',
    'corky' => 'courtney',
    'cory' => 'cornelius',
    'creasey' => 'lucretia',
    'crissy' => ['christina', 'christine'],
    'cy' => 'cyrus',
    'cyndi' => 'cynthia',
    'daisy' => 'margaret',
    'dan' => 'daniel',
    'danny' => 'daniel',
    'dave' => 'david',
    'davy' => 'david',
    'deb' => 'deborah',
    'debby' => 'deborah',
    'dee' => 'deanne',
    'deedee' => 'diedre',
    'delia' => ['bridget','cordelia', 'fidelia'],
    'della' => 'delilah',
    'derick' => 'frederick',
    'di' => ['diana', 'diane'],
    'dicey' => ['edith','elizabeth', 'eurydice'],
    'dick' => 'richard',
    'didi' => ['diana', 'diane'],
    'dodie' => 'delores',
    'dolly' => ['dorothy', 'margaret', 'martha'],
    'dora' => ['dorothy', 'eudora', 'isadora'],
    'dotty' => 'dorothy',
    'doug' => 'douglas',
    'drew' => 'andrew',
    'eck' => 'alexander',
    'ed' => ['edmund', 'edward'],
    'edie' => 'edith',
    'effie' => 'euphemia',
    'elaine' => 'eleanor',
    'eli' => ['elijah', 'elisha'],
    'ella' => ['eleanor', 'gabriella', 'luella'],
    'ellen' => 'eleanor',
    'ellie' => ['danielle', 'eleanor', 'emily', 'gabriella', 'luella'],
    'elly' => 'eleanor',
    'eloise' => 'heloise',
    'elsie' => 'elizabeth',
    'emily' => 'emeline',
    'emma' => 'emily',
    'eph' => 'ephraim',
    'erma' => 'emily',
    'erna' => 'earnestine',
    'ernie' => ['earnest', 'earnestine'],
    'etta' => 'loretta',
    'ev' => ['evangeline', 'evelyn'],
    'eve' => 'evelyn',
    'evie' => 'evelyn',
    'fan' => 'frances',
    'fanny' => ['frances', 'veronica'],
    'fay' => 'faith',
    'fina' => 'josephine',
    'flo' => 'florence',
    'flora' => 'florence',
    'flossie' => 'florence',
    'fran' => 'frances',
    'frank' => 'franklin',
    'frankie' => 'frances',
    'fred' => 'frederick',
    'freddie' => 'frederick',
    'fritz' => 'frederick',
    'gab' => 'gabriel',
    'gabby' => 'gabrielle',
    'gabe' => 'gabriel',
    'gene' => 'eugene',
    'genny' => 'gwenevere',
    'geoff' => 'geoffrey',
    'gerry' => 'gerald',
    'gus' => ['augustus', 'gustaf'],
    'ham' => 'hamilton',
    'hank' => 'henry',
    'hanna' => 'johanna',
    'hans' => ['johan', 'johannes'],
    'harry' => 'henry',
    'helen' => 'eleanor',
    'hester' => 'esther',
    'ibby' => 'elizabeth',
    'iggy' => 'ignatius',
    'issy' => ['isabella', 'isadora'],
    'jack' => 'john',
    'jackie' => 'jacqueline',
    'jake' => 'jacob',
    'jan' => 'jennifer',
    'jane' => ['janet', 'virginia'],
    'jed' => 'jedediah',
    'jeff' => 'jeffrey',
    'jennifer' => 'winifred',
    'jenny' => 'jennifer',
    'jeremy' => 'jeremiah',
    'jerry' => 'jeremiah',
    'jill' => 'julia',
    'jim' => 'james',
    'jimmy' => 'james',
    'joe' => 'joseph',
    'joey' => 'joseph',
    'johnny' => 'john',
    'jon' => 'jonathan',
    'josh' => 'joshua',
    'josie' => 'josephine',
    'joy' => 'joyce',
    'judy' => 'judith',
    'kate' => 'catherine',
    'kathy' => ['katherine', 'kathlene'],
    'katie' => 'katherine',
    'kissy' => 'calista',
    'kit' => 'christopher',
    'kitty' => 'catherine',
    'klaus' => 'nicholas',
    'lana' => 'eleanor',
    'len' => 'leonard',
    'lena' => 'magdalena',
    'leno' => 'felipe',
    'lenora' => 'eleanor',
    'leo' => 'leonard',
    'leon' => 'leonard',
    'lettie' => 'letitia',
    'lew' => 'lewis',
    'libby' => 'elizabeth',
    'lila' => 'delilah',
    'lisa' => 'elisa',
    'liz' => 'elizabeth',
    'liza' => 'elizabeth',
    'lizzie' => 'elizabeth',
    'lola' => 'delores',
    'lorrie' => 'lorraine',
    'lottie' => 'charlotte',
    'lou' => 'louis',
    'louie' => 'louis',
    'lucy' => ['lucille', 'lucinda'],
    'mabel' => 'mehitable',
    'maddie' => 'madeline',
    'maddy' => 'madeline',
    'madge' => 'margaret',
    'maggie' => 'margaret',
    'maggy' => 'margaret',
    'mame' => ['margaret', 'mary'],
    'mamie' => ['margaret', 'mary'],
    'manda' => 'amanda',
    'mandy' => ['amanda', 'samantha'],
    'manny' => 'emanuel',
    'manthy' => 'samantha',
    'marcy' => 'marcia',
    'marge' => ['margaret', 'marjorie'],
    'margie' => ['margaret', 'marjorie'],
    'marty' => 'martha',
    'marv' => 'marvin',
    'mat' => 'mathew',
    'matt' => ['mathew', 'matthias'],
    'maud' => ['magdalene', 'matilda'],
    'maude' => ['magdalene', 'matilda'],
    'maury' => 'maurice',
    'max' => ['maximilian', 'maxwell'],
    'may' => 'margaret',
    'meg' => 'margaret',
    'mel' => 'melvin',
    'mena' => 'philomena',
    'merv' => 'mervin',
    'mick' => 'michael',
    'mickey' => 'michael',
    'midge' => 'margaret',
    'mike' => 'michael',
    'millie' => 'emeline',
    'milly' => 'millicent',
    'milt' => 'milton',
    'mimi' => ['mary', 'wilhelmina'],
    'mina' => 'wilhelmina',
    'mini' => 'minerva',
    'minnie' => 'minerva',
    'mira' => ['elmira', 'mirabel'],
    'mischa' => 'michael',
    'mitch' => 'mitchell',
    'moll' => ['martha', 'mary'],
    'molly' => ['martha', 'mary'],
    'mona' => 'ramona',
    'mort' => ['mortimer', 'morton'],
    'morty' => ['mortimer', 'morton'],
    'mur' => 'muriel',
    'myra' => 'almira',
    'nab' => 'abel',
    'nabby' => 'abigail',
    'nacho' => 'ignacio',
    'nadia' => 'nadine',
    'nan' => ['ann', 'hannah' 'nancy'],
    'nana' => ['ann', 'hannah','nancy'],
    'nate' => ['nathan', 'nathaniel'],
    'ned' => ['edmund', 'edward', 'norton'],
    'neely' => 'cornelia',
    'neil' => ['cornelius', 'edward'],
    'nell' => ['cornelia', 'eleanor', 'ellen', 'helen'],
    'nellie' => 'helen',
    'nelly' => ['cornelia', 'eleanor', 'helen'],
    'nessie' => 'agnes',
    'nettie' => 'jeanette',
    'netty' => 'henrietta',
    'nicie' => 'eunice',
    'nick' => ['dominic', 'nicholas'],
    'nicy' => 'eunice',
    'nikki' => 'nicole',
    'nina' => 'ann',
    'nita' => ['anita', 'juanita'],
    'nora' => ['eleanor', 'elnora'],
    'norm' => 'norman',
    'obed' => 'obediah',
    'ollie' => 'oliver',
    'ora' => ['aurillia', 'corinne'],
    'pablo' => 'paul',
    'pacho' => 'francisco',
    'paco' => 'francisco',
    'paddy' => 'patrick',
    'pam' => 'pamela',
    'pancho' => 'francisco',
    'pat' => ['martha', 'matilda', 'patricia', 'patrick'],
    'patsy' => ['martha', 'matilda', 'patricia','martha', 'matilda', 'patricia'],
    'peg' => 'margaret',
    'peggy' => 'margaret',
    'penny' => 'penelope',
    'pepa' => 'josefa',
    'pepe' => 'jose',
    'percy' => 'percival',
    'pete' => 'peter',
    'phelia' => 'orphelia',
    'phil' => 'philip',
    'polly' => ['mary', 'paula'],
    'prissy' => 'priscilla',
    'prudy' => 'prudence',
    'quil' => 'aquilla',
    'quillie' => 'aquilla',
    'rafe' => 'raphael',
    'randy' => ['miranda', 'randall', 'randolph'],
    'rasmus' => 'erasmus',
    'ray' => 'raymond',
    'reba' => 'rebecca',
    'reg' => 'reginald',
    'reggie' => 'reginald',
    'rena' => 'irene',
    'rich' => 'richard',
    'rick' => ['eric', 'frederick', 'garrick', 'patrick','richard'],
    'rita' => ['clarita', 'margaret', 'margarita', 'norita'],
    'rob' => 'robert',
    'rod' => ['roderick', 'rodney', 'rodrigo'],
    'rodie' => 'rhoda',
    'ron' => ['aaron', 'reginald', 'ronald'],
    'ronnie' => 'veronica',
    'ronny' => 'ronald',
    'rosie' => ['rosalind', 'rosemary', 'rosetta'],
    'roxy' => 'roxanne',
    'roy' => 'leroy',
    'rudy' => 'rudolph',
    'russ' => 'russell',
    'sadie' => ['sally', 'sarah'],
    'sal' => 'sarah',
    'sally' => 'sarah',
    'sam' => 'samuel',
    'sandy' => ['alexander', 'sandra'],
    'sene' => 'asenath',
    'senga' => 'agnes',
    'senie' => 'asenath',
    'sherm' => 'sherman',
    'si' => ['cyrus', 'matthias','silas'],
    'sibella' => 'isabella',
    'sid' => 'sidney',
    'silla' => [ 'drusilla', 'priscilla'],
    'silvie' => 'silvia',
    'sis' => ['cecilia', 'frances'],
    'sissy' => 'cecilia',
    'sol' => 'solomon',
    'stacia' => 'eustacia',
    'stacy' => ['anastasia', 'eustacia'],
    'stan' => ['stanislas', 'stanly'],
    'stella' => ['estella', 'esther'],
    'steve' => 'steven',
    'steven' => 'stephen',
    'stew' => 'stewart',
    'sue' => ['susan', 'suzanne'],
    'sukey' => 'suzanna',
    'susie' => ['susan', 'suzanne'],
    'suzy' => ['susan', 'suzanne'],
    'tad' => ['edward', 'thadeus'],
    'ted' => ['edmund', 'edward', 'theodore'],
    'teddy' => ['edward', 'theodore'],
    'telly' => 'aristotle',
    'terry' => 'theresa',
    'tess' => ['elizabeth', 'theresa'],
    'theo' => ['theobald', 'theodore'],
    'tia' => 'antonia',
    'tibbie' => 'isabella',
    'tilda' => 'matilda',
    'tilly' => ['matilda', 'otilia'],
    'tim' => 'timothy',
    'timmy' => 'timothy',
    'tina' => ['albertina', 'augustina', 'christina', 'christine','earnestine', 'justina','martina'],
    'tish' => 'letitia',
    'toby' => 'tobias',
    'tom' => 'thomas',
    'tony' => 'anthony',
    'tracy' => 'theresa',
    'trina' => 'katherina',
    'trixie' => 'beatrice',
    'trudi' => 'gertrude',
    'trudy' => 'gertrude',
    'ursie' => 'ursula',
    'ursy' => 'ursula',
    'vangie' => 'evangeline',
    'vern' => 'vernon',
    'vi' => ['viola', 'violet'],
    'vic' => 'victor',
    'vicky' => 'victoria',
    'vin' => ['galvin', 'vincent'],
    'vina' => ['alvina', 'lavina'],
    'vinny' => 'vincent',
    'virg' => 'virgil',
    'virgie' => 'virginia',
    'viv' => 'vivian',
    'vonnie' => 'yvonne',
    'wally' => ['wallace', 'walter'],
    'walt' => 'walter',
    'web' => 'webster',
    'wendy' => 'gwendolen',
    'wes' => 'wesley',
    'will' => 'william',
    'willie' => 'wilhelmina',
    'willy' => 'william',
    'winn' => 'edwin',
    'winnie' => ['edwina', 'winifred'],
    'woody' => 'woodrow',
    'xina' => 'christina',
    'zac' => 'isaac',
    'zach' => 'zachariah',
    'zak' => 'isaac',
    'zeb' => 'zebulon',
    'zed' => 'zedekiah',
    'zeke' => 'ezekiel',
    'zena' => 'albertina',
    'zeph' => 'zephaniah'
  }

  LONG_FIRST_NAMES = {
    'abner' => ['ab'],
    'abigail' => ['abbie', 'abby', 'nabby'],
    'abram' => ['abe'],
    'acera' => ['acer'],
    'adeline' => ['ada'],
    'adelaide' => ['addie'],
    'agatha' => ['ag', 'aggy'],
    'inez' => ['agnes'],
    'alfred' => ['al', 'alf'],
    'alexander' => ['alec', 'alex', 'eck'],
    'amelia' => ['amy'],
    'andrew' => ['andy','drew'],
    'angeline' => ['angie'],
    'susanna' => ['ann', 'anna', 'anne', 'annie'],
    'anna' => ['annette'],
    'apollonia' => ['appy'],
    'archibald' => ['archy'],
    'arnold' => ['arnie', 'arny'],
    'arthur' => ['art', 'arty'],
    'barbara' => ['bab', 'babs', 'barb'],
    'barnabas' => ['barney'],
    'bartholomew' => ['bart', 'barty'],
    'sebastian' => ['bass'],
    'beatrice' => ['bea', 'beattie', 'trixie'],
    'rebecca' => ['becky', 'reba'],
    'mirabel' => ['bella', 'mira'],
    'sybil' => ['belle'],
    'benjamin' => ['ben'],
    'egbert' => ['bert', 'burt'],
    'gilbert' => ['bertie'],
    'elizabeth' => ['bess', 'bessie', 'beth', 'betsy', 'betty', 'elsie', 'ibby', 'libby', 'liz', 'liza', 'lizzie'],
    'alberto' => ['beto'],
    'beverly' => ['bev'],
    'william' => ['bill', 'will', 'willy'],
    'robert' => ['bob', 'rob'],
    'calvin' => ['cal'],
    'caroline' => ['carol'],
    'cassandra' => ['cassie'],
    'catherine' => ['cathy', 'caty', 'kate', 'kitty'],
    'cecilia' => ['cecily', 'sissy'],
    'charles' => ['charlie', 'chuck'],
    'chester' => ['chet'],
    'crystal' => ['chris'],
    'lucinda' => ['cindy', 'lucy'],
    'clarissa' => ['cissy'],
    'nicholas' => ['claus', 'klaus', 'nick'],
    'cleatus' => ['cleat'],
    'clementine' => ['clem'],
    'clifton' => ['cliff'],
    'chloe' => ['clo'],
    'cornelia' => ['connie', 'conny', 'neely'],
    'corinne' => ['cora', 'ora'],
    'courtney' => ['corky'],
    'cornelius' => ['cory'],
    'lucretia' => ['creasey'],
    'christine' => ['crissy'],
    'cyrus' => ['cy'],
    'cynthia' => ['cyndi'],
    'margaret' => ['daisy', 'madge', 'maggie', 'maggy', 'may', 'meg', 'midge', 'peg', 'peggy'],
    'daniel' => ['dan', 'danny'],
    'david' => ['dave', 'davy'],
    'deborah' => ['deb', 'debby'],
    'deanne' => ['dee'],
    'diedre' => ['deedee'],
    'fidelia' => ['delia'],
    'delilah' => ['della', 'lila'],
    'frederick' => ['derick', 'fred', 'freddie', 'fritz'],
    'diane' => ['di', 'didi'],
    'eurydice' => ['dicey'],
    'richard' => ['dick', 'rich', 'rick'],
    'delores' => ['dodie', 'lola'],
    'martha' => ['dolly', 'marty'],
    'isadora' => ['dora', 'issy'],
    'dorothy' => ['dotty'],
    'douglas' => ['doug'],
    'edward' => ['ed', 'neil'],
    'edith' => ['edie'],
    'euphemia' => ['effie'],
    'eleanor' => ['elaine', 'ellen', 'elly', 'helen', 'lana', 'lenora'],
    'elisha' => ['eli'],
    'luella' => ['ella', 'ellie'],
    'heloise' => ['eloise'],
    'emeline' => ['emily', 'millie'],
    'emily' => ['emma', 'erma'],
    'ephraim' => ['eph'],
    'earnestine' => ['erna', 'ernie'],
    'loretta' => ['etta'],
    'evelyn' => ['ev', 'eve', 'evie'],
    'frances' => ['fan', 'fran', 'frankie', 'sis'],
    'veronica' => ['fanny', 'ronnie'],
    'faith' => ['fay'],
    'josephine' => ['fina', 'josie'],
    'florence' => ['flo', 'flora', 'flossie'],
    'franklin' => ['frank'],
    'gabriel' => ['gab', 'gabe'],
    'gabrielle' => ['gabby'],
    'eugene' => ['gene'],
    'gwenevere' => ['genny'],
    'geoffrey' => ['geoff'],
    'gerald' => ['gerry'],
    'gustaf' => ['gus'],
    'hamilton' => ['ham'],
    'henry' => ['hank', 'harry'],
    'johanna' => ['hanna'],
    'johannes' => ['hans'],
    'esther' => ['hester', 'stella'],
    'ignatius' => ['iggy'],
    'john' => ['jack', 'johnny'],
    'jacqueline' => ['jackie'],
    'jacob' => ['jake'],
    'jennifer' => ['jan', 'jenny'],
    'virginia' => ['jane', 'virgie'],
    'jedediah' => ['jed'],
    'jeffrey' => ['jeff'],
    'winifred' => ['jennifer', 'winnie'],
    'jeremiah' => ['jeremy', 'jerry'],
    'julia' => ['jill'],
    'james' => ['jim', 'jimmy'],
    'joseph' => ['joe', 'joey'],
    'jonathan' => ['jon'],
    'joshua' => ['josh'],
    'joyce' => ['joy'],
    'judith' => ['judy'],
    'kathlene' => ['kathy'],
    'katherine' => ['katie'],
    'calista' => ['kissy'],
    'christopher' => ['kit'],
    'leonard' => ['len', 'leo', 'leon'],
    'magdalena' => ['lena'],
    'felipe' => ['leno'],
    'letitia' => ['lettie', 'tish'],
    'lewis' => ['lew'],
    'elisa' => ['lisa'],
    'lorraine' => ['lorrie'],
    'charlotte' => ['lottie'],
    'louis' => ['lou', 'louie'],
    'mehitable' => ['mabel'],
    'madeline' => ['maddie', 'maddy'],
    'mary' => ['mame', 'mamie', 'moll', 'molly'],
    'amanda' => ['manda'],
    'samantha' => ['mandy', 'manthy'],
    'emanuel' => ['manny'],
    'marcia' => ['marcy'],
    'marjorie' => ['marge', 'margie'],
    'marvin' => ['marv'],
    'mathew' => ['mat'],
    'matthias' => ['matt'],
    'matilda' => ['maud', 'maude', 'tilda'],
    'maurice' => ['maury'],
    'maxwell' => ['max'],
    'melvin' => ['mel'],
    'philomena' => ['mena'],
    'mervin' => ['merv'],
    'michael' => ['mick', 'mickey', 'mike', 'mischa'],
    'millicent' => ['milly'],
    'milton' => ['milt'],
    'wilhelmina' => ['mimi', 'mina', 'willie'],
    'minerva' => ['mini', 'minnie'],
    'mitchell' => ['mitch'],
    'ramona' => ['mona'],
    'morton' => ['mort', 'morty'],
    'muriel' => ['mur'],
    'almira' => ['myra'],
    'abel' => ['nab'],
    'ignacio' => ['nacho'],
    'nadine' => ['nadia'],
    'nancy' => ['nan', 'nana'],
    'nathaniel' => ['nate'],
    'norton' => ['ned'],
    'helen' => ['nell', 'nellie', 'nelly'],
    'agnes' => ['nessie', 'senga'],
    'jeanette' => ['nettie'],
    'henrietta' => ['netty'],
    'eunice' => ['nicie', 'nicy'],
    'nicole' => ['nikki'],
    'ann' => ['nina'],
    'juanita' => ['nita'],
    'elnora' => ['nora'],
    'norman' => ['norm'],
    'obediah' => ['obed'],
    'oliver' => ['ollie'],
    'paul' => ['pablo'],
    'francisco' => ['pacho', 'paco', 'pancho'],
    'patrick' => ['paddy', 'pat'],
    'pamela' => ['pam'],
    'patricia' => ['patsy', 'patty'],
    'penelope' => ['penny'],
    'josefa' => ['pepa'],
    'jose' => ['pepe'],
    'percival' => ['percy'],
    'peter' => ['pete'],
    'orphelia' => ['phelia'],
    'philip' => ['phil'],
    'paula' => ['polly'],
    'priscilla' => ['prissy', 'silla'],
    'prudence' => ['prudy'],
    'aquilla' => ['quil', 'quillie'],
    'raphael' => ['rafe'],
    'randolph' => ['randy'],
    'erasmus' => ['rasmus'],
    'raymond' => ['ray'],
    'reginald' => ['reg', 'reggie'],
    'irene' => ['rena'],
    'norita' => ['rita'],
    'rodrigo' => ['rod'],
    'rhoda' => ['rodie'],
    'ronald' => ['ron', 'ronny'],
    'rosetta' => ['rosie'],
    'roxanne' => ['roxy'],
    'leroy' => ['roy'],
    'rudolph' => ['rudy'],
    'russell' => ['russ'],
    'sarah' => ['sadie', 'sal', 'sally'],
    'samuel' => ['sam'],
    'sandra' => ['sandy'],
    'asenath' => ['sene', 'senie'],
    'sherman' => ['sherm'],
    'silas' => ['si'],
    'isabella' => ['sibella', 'tibbie'],
    'sidney' => ['sid'],
    'silvia' => ['silvie'],
    'solomon' => ['sol'],
    'eustacia' => ['stacia', 'stacy'],
    'stanly' => ['stan'],
    'steven' => ['steve'],
    'stephen' => ['steven'],
    'stewart' => ['stew'],
    'suzanne' => ['sue', 'susie', 'suzy'],
    'suzanna' => ['sukey'],
    'thadeus' => ['tad'],
    'theodore' => ['ted', 'teddy', 'theo'],
    'aristotle' => ['telly'],
    'theresa' => ['terry', 'tess', 'tracy'],
    'antonia' => ['tia'],
    'otilia' => ['tilly'],
    'timothy' => ['tim', 'timmy'],
    'martina' => ['tina'],
    'tobias' => ['toby'],
    'thomas' => ['tom'],
    'anthony' => ['tony'],
    'katherina' => ['trina'],
    'gertrude' => ['trudi', 'trudy'],
    'ursula' => ['ursie', 'ursy'],
    'evangeline' => ['vangie'],
    'vernon' => ['vern'],
    'violet' => ['vi'],
    'victor' => ['vic'],
    'victoria' => ['vicky'],
    'vincent' => ['vin', 'vinny'],
    'lavina' => ['vina'],
    'virgil' => ['virg'],
    'vivian' => ['viv'],
    'yvonne' => ['vonnie'],
    'walter' => ['wally', 'walt'],
    'webster' => ['web'],
    'gwendolen' => ['wendy'],
    'wesley' => ['wes'],
    'edwin' => ['winn'],
    'woodrow' => ['woody'],
    'christina' => ['xina'],
    'isaac' => ['zac', 'zak'],
    'zachariah' => ['zach'],
    'zebulon' => ['zeb'],
    'zedekiah' => ['zed'],
    'ezekiel' => ['zeke'],
    'albertina' => ['zena'],
    'zephaniah' => ['zeph']
  }
end
