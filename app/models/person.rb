class Person < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :person

  def titleize_names
    %w(name_prefix name_first name_middle name_last name_suffix name_nick).each do |field|
      send(:"#{field}=", send(field.to_sym).gsub(/^\p{Ll}/) { |m| m.upcase }) if send(field.to_sym).present?
    end
  end

  def name_regex(require_first = true)
    titleize_names
    last_re = last_name_regex_str
    first = name_first

    if names = SHORT_FIRST_NAMES[first.downcase]
      first = [first].concat(Array(names).map(&:titleize)).join(' ')
    end

    fm = (require_first ? '' : first.to_s + ' ') + name_middle.to_s + ' ' + name_nick.to_s
    fm_ary = fm.split(/[[[:space:]]-]+/)
    initials = ''

    fm_ary.map! do |fm|
      length = fm.gsub(/[^\p{L}]/u, '').length
      fm.gsub!(/(\p{Ll})/u) { |m| "[#{m}#{m.upcase}]" }
      initials += fm[0].upcase
      if length > 3
        offset = fm.index(']', fm.index(']') + 1) + 1
        str = fm[offset..-1].gsub(']', ']?')
        fm = fm.slice(0, offset) + str
      end
      fm
    end

    fm = fm_ary.join('|')
    separator = '\b([\'"\(\)\.]{0,3}[[:space:]]+|\.[[:space:]]*|[[:space:]]?-[[:space:]]?)?'
    initials = initials.present? ? '[' + initials + ']' : ''

    if require_first
      nf_ary = first.split(/[[:space:]]+/mu)
      nf_ary.map! { |nf| nf.gsub(/(\p{Ll})/u) { |m| "[#{m}#{m.upcase}]" } }
      first = nf_ary.join('|')
      re = '((\b(' + first + ')' + separator + '(' + fm + '|' + initials + ')?' + separator + '((\p{L}|[\.\'\-])+' + separator + ')?)+((' + last_re + ')\b))'
    else
      re = '((\b(' + fm + '|' + initials + ')' + separator + '((\p{L}|[\.\'\-])+' + separator + ')?)+((' + last_re + ')\b))'
    end

    Regexp.new(re)
  end

  def last_name_regex_str
    name_last.gsub(/(\p{Ll})/u) { |m| "[#{m}#{m.upcase}]" }.gsub(/[[[:space:]]-]+/mu, '[[[:space:]]-]+')
  end

  def gender
    if gender_id == 1
      return 'Female'
    elsif gender_id == 2
      return 'Male'
    else
      return nil
    end
  end


  def self.same_first_names(name)
    [].concat([SHORT_FIRST_NAMES[name.downcase]]).concat(LONG_FIRST_NAMES.fetch(name.downcase, [])).compact
  end

  SHORT_FIRST_NAMES = {
    'ab' => 'abner', 'abbie' => 'abigail', 'abby' => 'abigail', 'abe' => 'abel', 'abe' => 'abraham', 'abe' => 'abram', 'acer' => 'acera', 'ada' => 'adeline', 'addie' => 'adelaide', 'ag' => 'agatha', 'aggy' => 'agatha', 'agnes' => 'agatha', 'agnes' => 'inez', 'al' => 'albert', 'al' => 'alexander', 'al' => 'alfred', 'alec' => 'alexander', 'alex' => 'alexander', 'alf' => 'alfred', 'amy' => 'amanda', 'amy' => 'amelia', 'andy' => 'andreas', 'andy' => 'andrew', 'angie' => 'angeline', 'ann' => 'deanne', 'ann' => 'hannah', 'ann' => 'susanna', 'anna' => 'hannah', 'anna' => 'susanna', 'anne' => 'hannah', 'anne' => 'susanna', 'annette' => 'ann', 'annette' => 'anna', 'annie' => 'ann', 'annie' => 'anna', 'annie' => 'hannah', 'annie' => 'susanna', 'appy' => 'apollonia', 'archy' => 'archibald', 'arnie' => 'arnold', 'arny' => 'arnold', 'art' => 'artemis', 'art' => 'arthur', 'arty' => 'arthur', 'bab' => 'barbara', 'babs' => 'barbara', 'barb' => 'barbara', 'barney' => 'barnabas', 'bart' => 'bartholomew', 'barty' => 'bartholomew', 'bass' => 'sebastian', 'bea' => 'beatta', 'bea' => 'beatrice', 'beattie' => 'beatrice', 'becky' => 'rebecca', 'bella' => 'arabella', 'bella' => 'belinda', 'bella' => 'elizabeth', 'bella' => 'isabel', 'bella' => 'isabella', 'bella' => 'mirabel', 'belle' => 'mabel', 'belle' => 'sybil', 'ben' => 'benedict', 'ben' => 'benjamin', 'bert' => 'delbert', 'bert' => 'egbert', 'bertie' => 'albert', 'bertie' => 'gilbert', 'bess' => 'elizabeth', 'bessie' => 'elizabeth', 'beth' => 'elizabeth', 'beto' => 'alberto', 'betsy' => 'elizabeth', 'betty' => 'elizabeth', 'bev' => 'beverly', 'bill' => 'william', 'bob' => 'robert', 'burt' => 'egbert', 'cal' => 'caleb', 'cal' => 'calvin', 'carol' => 'caroline', 'cassie' => 'cassandra', 'cathy' => 'catherine', 'caty' => 'catherine', 'cecily' => 'cecilia', 'charlie' => 'charles', 'chet' => 'chester', 'chris' => 'christian', 'chris' => 'christine', 'chris' => 'crystal', 'chuck' => 'charles', 'cindy' => 'cynthia', 'cindy' => 'lucinda', 'cissy' => 'cecilia', 'cissy' => 'clarissa', 'claus' => 'nicholas', 'cleat' => 'cleatus', 'clem' => 'clement', 'clem' => 'clementine', 'cliff' => 'clifford', 'cliff' => 'clifton', 'clo' => 'chloe', 'connie' => 'constance', 'connie' => 'cornelia', 'conny' => 'cornelia', 'cora' => 'corinne', 'corky' => 'courtney', 'cory' => 'cornelius', 'creasey' => 'lucretia', 'crissy' => 'christina', 'crissy' => 'christine', 'cy' => 'cyrus', 'cyndi' => 'cynthia', 'daisy' => 'margaret', 'dan' => 'daniel', 'danny' => 'daniel', 'dave' => 'david', 'davy' => 'david', 'deb' => 'deborah', 'debby' => 'deborah', 'dee' => 'deanne', 'deedee' => 'diedre', 'delia' => 'bridget', 'delia' => 'cordelia', 'delia' => 'fidelia', 'della' => 'delilah', 'derick' => 'frederick', 'di' => 'diana', 'di' => 'diane', 'dicey' => 'edith', 'dicey' => 'elizabeth', 'dicey' => 'eurydice', 'dick' => 'richard', 'didi' => 'diana', 'didi' => 'diane', 'dodie' => 'delores', 'dolly' => 'dorothy', 'dolly' => 'margaret', 'dolly' => 'martha', 'dora' => 'dorothy', 'dora' => 'eudora', 'dora' => 'isadora', 'dotty' => 'dorothy', 'doug' => 'douglas', 'drew' => 'andrew', 'eck' => 'alexander', 'ed' => 'edmund', 'ed' => 'edward', 'edie' => 'edith', 'effie' => 'euphemia', 'elaine' => 'eleanor', 'eli' => 'elijah', 'eli' => 'elisha', 'ella' => 'eleanor', 'ella' => 'gabriella', 'ella' => 'luella', 'ellen' => 'eleanor', 'ellie' => 'danielle', 'ellie' => 'eleanor', 'ellie' => 'emily', 'ellie' => 'gabriella', 'ellie' => 'luella', 'elly' => 'eleanor', 'eloise' => 'heloise', 'elsie' => 'elizabeth', 'emily' => 'emeline', 'emma' => 'emily', 'eph' => 'ephraim', 'erma' => 'emily', 'erna' => 'earnestine', 'ernie' => 'earnest', 'ernie' => 'earnestine', 'etta' => 'loretta', 'ev' => 'evangeline', 'ev' => 'evelyn', 'eve' => 'evelyn', 'evie' => 'evelyn', 'fan' => 'frances', 'fanny' => 'frances', 'fanny' => 'veronica', 'fay' => 'faith', 'fina' => 'josephine', 'flo' => 'florence', 'flora' => 'florence', 'flossie' => 'florence', 'fran' => 'frances', 'frank' => 'franklin', 'frankie' => 'frances', 'fred' => 'frederick', 'freddie' => 'frederick', 'fritz' => 'frederick', 'gab' => 'gabriel', 'gabby' => 'gabrielle', 'gabe' => 'gabriel', 'gene' => 'eugene', 'genny' => 'gwenevere', 'geoff' => 'geoffrey', 'gerry' => 'gerald', 'gus' => 'augustus', 'gus' => 'gustaf', 'ham' => 'hamilton', 'hank' => 'henry', 'hanna' => 'johanna', 'hans' => 'johan', 'hans' => 'johannes', 'harry' => 'henry', 'helen' => 'eleanor', 'hester' => 'esther', 'ibby' => 'elizabeth', 'iggy' => 'ignatius', 'issy' => 'isabella', 'issy' => 'isadora', 'jack' => 'john', 'jackie' => 'jacqueline', 'jake' => 'jacob', 'jan' => 'jennifer', 'jane' => 'janet', 'jane' => 'virginia', 'jed' => 'jedediah', 'jeff' => 'jeffrey', 'jennifer' => 'winifred', 'jenny' => 'jennifer', 'jeremy' => 'jeremiah', 'jerry' => 'jeremiah', 'jill' => 'julia', 'jim' => 'james', 'jimmy' => 'james', 'joe' => 'joseph', 'joey' => 'joseph', 'johnny' => 'john', 'jon' => 'jonathan', 'josh' => 'joshua', 'josie' => 'josephine', 'joy' => 'joyce', 'judy' => 'judith', 'kate' => 'catherine', 'kathy' => 'katherine', 'kathy' => 'kathlene', 'katie' => 'katherine', 'kissy' => 'calista', 'kit' => 'christopher', 'kitty' => 'catherine', 'klaus' => 'nicholas', 'lana' => 'eleanor', 'len' => 'leonard', 'lena' => 'magdalena', 'leno' => 'felipe', 'lenora' => 'eleanor', 'leo' => 'leonard', 'leon' => 'leonard', 'lettie' => 'letitia', 'lew' => 'lewis', 'libby' => 'elizabeth', 'lila' => 'delilah', 'lisa' => 'elisa', 'liz' => 'elizabeth', 'liza' => 'elizabeth', 'lizzie' => 'elizabeth', 'lola' => 'delores', 'lorrie' => 'lorraine', 'lottie' => 'charlotte', 'lou' => 'louis', 'louie' => 'louis', 'lucy' => 'lucille', 'lucy' => 'lucinda', 'mabel' => 'mehitable', 'maddie' => 'madeline', 'maddy' => 'madeline', 'madge' => 'margaret', 'maggie' => 'margaret', 'maggy' => 'margaret', 'mame' => 'margaret', 'mame' => 'mary', 'mamie' => 'margaret', 'mamie' => 'mary', 'manda' => 'amanda', 'mandy' => 'amanda', 'mandy' => 'samantha', 'manny' => 'emanuel', 'manthy' => 'samantha', 'marcy' => 'marcia', 'marge' => 'margaret', 'marge' => 'marjorie', 'margie' => 'margaret', 'margie' => 'marjorie', 'marty' => 'martha', 'marv' => 'marvin', 'mat' => 'mathew', 'matt' => 'mathew', 'matt' => 'matthias', 'maud' => 'magdalene', 'maud' => 'matilda', 'maude' => 'magdalene', 'maude' => 'matilda', 'maury' => 'maurice', 'max' => 'maximilian', 'max' => 'maxwell', 'may' => 'margaret', 'meg' => 'margaret', 'mel' => 'melvin', 'mena' => 'philomena', 'merv' => 'mervin', 'mick' => 'michael', 'mickey' => 'michael', 'midge' => 'margaret', 'mike' => 'michael', 'millie' => 'emeline', 'milly' => 'millicent', 'milt' => 'milton', 'mimi' => 'mary', 'mimi' => 'wilhelmina', 'mina' => 'wilhelmina', 'mini' => 'minerva', 'minnie' => 'minerva', 'mira' => 'elmira', 'mira' => 'mirabel', 'mischa' => 'michael', 'mitch' => 'mitchell', 'moll' => 'martha', 'moll' => 'mary', 'molly' => 'martha', 'molly' => 'mary', 'mona' => 'ramona', 'mort' => 'mortimer', 'mort' => 'morton', 'morty' => 'mortimer', 'morty' => 'morton', 'mur' => 'muriel', 'myra' => 'almira', 'nab' => 'abel', 'nabby' => 'abigail', 'nacho' => 'ignacio', 'nadia' => 'nadine', 'nan' => 'ann', 'nan' => 'hannah', 'nan' => 'nancy', 'nana' => 'ann', 'nana' => 'hannah', 'nana' => 'nancy', 'nate' => 'nathan', 'nate' => 'nathaniel', 'ned' => 'edmund', 'ned' => 'edward', 'ned' => 'norton', 'neely' => 'cornelia', 'neil' => 'cornelius', 'neil' => 'edward', 'nell' => 'cornelia', 'nell' => 'eleanor', 'nell' => 'ellen', 'nell' => 'helen', 'nellie' => 'helen', 'nelly' => 'cornelia', 'nelly' => 'eleanor', 'nelly' => 'helen', 'nessie' => 'agnes', 'nettie' => 'jeanette', 'netty' => 'henrietta', 'nicie' => 'eunice', 'nick' => 'dominic', 'nick' => 'nicholas', 'nicy' => 'eunice', 'nikki' => 'nicole', 'nina' => 'ann', 'nita' => 'anita', 'nita' => 'juanita', 'nora' => 'eleanor', 'nora' => 'elnora', 'norm' => 'norman', 'obed' => 'obediah', 'ollie' => 'oliver', 'ora' => 'aurillia', 'ora' => 'corinne', 'pablo' => 'paul', 'pacho' => 'francisco', 'paco' => 'francisco', 'paddy' => 'patrick', 'pam' => 'pamela', 'pancho' => 'francisco', 'pat' => 'martha', 'pat' => 'matilda', 'pat' => 'patricia', 'pat' => 'patrick', 'patsy' => 'martha', 'patsy' => 'matilda', 'patsy' => 'patricia', 'patty' => 'martha', 'patty' => 'matilda', 'patty' => 'patricia', 'peg' => 'margaret', 'peggy' => 'margaret', 'penny' => 'penelope', 'pepa' => 'josefa', 'pepe' => 'jose', 'percy' => 'percival', 'pete' => 'peter', 'phelia' => 'orphelia', 'phil' => 'philip', 'polly' => 'mary', 'polly' => 'paula', 'prissy' => 'priscilla', 'prudy' => 'prudence', 'quil' => 'aquilla', 'quillie' => 'aquilla', 'rafe' => 'raphael', 'randy' => 'miranda', 'randy' => 'randall', 'randy' => 'randolph', 'rasmus' => 'erasmus', 'ray' => 'raymond', 'reba' => 'rebecca', 'reg' => 'reginald', 'reggie' => 'reginald', 'rena' => 'irene', 'rich' => 'richard', 'rick' => 'eric', 'rick' => 'frederick', 'rick' => 'garrick', 'rick' => 'patrick', 'rick' => 'richard', 'rita' => 'clarita', 'rita' => 'margaret', 'rita' => 'margarita', 'rita' => 'norita', 'rob' => 'robert', 'rod' => 'roderick', 'rod' => 'rodney', 'rod' => 'rodrigo', 'rodie' => 'rhoda', 'ron' => 'aaron', 'ron' => 'reginald', 'ron' => 'ronald', 'ronnie' => 'veronica', 'ronny' => 'ronald', 'rosie' => 'rosalind', 'rosie' => 'rosemary', 'rosie' => 'rosetta', 'roxy' => 'roxanne', 'roy' => 'leroy', 'rudy' => 'rudolph', 'russ' => 'russell', 'sadie' => 'sally', 'sadie' => 'sarah', 'sal' => 'sarah', 'sally' => 'sarah', 'sam' => 'samuel', 'sandy' => 'alexander', 'sandy' => 'sandra', 'sene' => 'asenath', 'senga' => 'agnes', 'senie' => 'asenath', 'sherm' => 'sherman', 'si' => 'cyrus', 'si' => 'matthias', 'si' => 'silas', 'sibella' => 'isabella', 'sid' => 'sidney', 'silla' => 'drusilla', 'silla' => 'priscilla', 'silvie' => 'silvia', 'sis' => 'cecilia', 'sis' => 'frances', 'sissy' => 'cecilia', 'sol' => 'solomon', 'stacia' => 'eustacia', 'stacy' => 'anastasia', 'stacy' => 'eustacia', 'stan' => 'stanislas', 'stan' => 'stanly', 'stella' => 'estella', 'stella' => 'esther', 'steve' => 'steven', 'steven' => 'stephen', 'stew' => 'stewart', 'sue' => 'susan', 'sue' => 'suzanne', 'sukey' => 'suzanna', 'susie' => 'susan', 'susie' => 'suzanne', 'suzy' => 'susan', 'suzy' => 'suzanne', 'tad' => 'edward', 'tad' => 'thadeus', 'ted' => 'edmund', 'ted' => 'edward', 'ted' => 'theodore', 'teddy' => 'edward', 'teddy' => 'theodore', 'telly' => 'aristotle', 'terry' => 'theresa', 'tess' => 'elizabeth', 'tess' => 'theresa', 'theo' => 'theobald', 'theo' => 'theodore', 'tia' => 'antonia', 'tibbie' => 'isabella', 'tilda' => 'matilda', 'tilly' => 'matilda', 'tilly' => 'otilia', 'tim' => 'timothy', 'timmy' => 'timothy', 'tina' => 'albertina', 'tina' => 'augustina', 'tina' => 'christina', 'tina' => 'christine', 'tina' => 'earnestine', 'tina' => 'justina', 'tina' => 'martina', 'tish' => 'letitia', 'toby' => 'tobias', 'tom' => 'thomas', 'tony' => 'anthony', 'tracy' => 'theresa', 'trina' => 'katherina', 'trixie' => 'beatrice', 'trudi' => 'gertrude', 'trudy' => 'gertrude', 'ursie' => 'ursula', 'ursy' => 'ursula', 'vangie' => 'evangeline', 'vern' => 'vernon', 'vi' => 'viola', 'vi' => 'violet', 'vic' => 'victor', 'vicky' => 'victoria', 'vin' => 'galvin', 'vin' => 'vincent', 'vina' => 'alvina', 'vina' => 'lavina', 'vinny' => 'vincent', 'virg' => 'virgil', 'virgie' => 'virginia', 'viv' => 'vivian', 'vonnie' => 'yvonne', 'wally' => 'wallace', 'wally' => 'walter', 'walt' => 'walter', 'web' => 'webster', 'wendy' => 'gwendolen', 'wes' => 'wesley', 'will' => 'william', 'willie' => 'wilhelmina', 'willy' => 'william', 'winn' => 'edwin', 'winnie' => 'edwina', 'winnie' => 'winifred', 'woody' => 'woodrow', 'xina' => 'christina', 'zac' => 'isaac', 'zach' => 'zachariah', 'zak' => 'isaac', 'zeb' => 'zebulon', 'zed' => 'zedekiah', 'zeke' => 'ezekiel', 'zena' => 'albertina', 'zeph' => 'zephaniah'
  }

  LONG_FIRST_NAMES = {'abner' => ['ab'], 'abigail' => ['abbie', 'abby', 'nabby'], 'abram' => ['abe'], 'acera' => ['acer'], 'adeline' => ['ada'], 'adelaide' => ['addie'], 'agatha' => ['ag', 'aggy'], 'inez' => ['agnes'], 'alfred' => ['al', 'alf'], 'alexander' => ['alec', 'alex', 'eck'], 'amelia' => ['amy'], 'andrew' => ['andy', 'drew'], 'angeline' => ['angie'], 'susanna' => ['ann', 'anna', 'anne', 'annie'], 'anna' => ['annette'], 'apollonia' => ['appy'], 'archibald' => ['archy'], 'arnold' => ['arnie', 'arny'], 'arthur' => ['art', 'arty'], 'barbara' => ['bab', 'babs', 'barb'], 'barnabas' => ['barney'], 'bartholomew' => ['bart', 'barty'], 'sebastian' => ['bass'], 'beatrice' => ['bea', 'beattie', 'trixie'], 'rebecca' => ['becky', 'reba'], 'mirabel' => ['bella', 'mira'], 'sybil' => ['belle'], 'benjamin' => ['ben'], 'egbert' => ['bert', 'burt'], 'gilbert' => ['bertie'], 'elizabeth' => ['bess', 'bessie', 'beth', 'betsy', 'betty', 'elsie', 'ibby', 'libby', 'liz', 'liza', 'lizzie'], 'alberto' => ['beto'], 'beverly' => ['bev'], 'william' => ['bill', 'will', 'willy'], 'robert' => ['bob', 'rob'], 'calvin' => ['cal'], 'caroline' => ['carol'], 'cassandra' => ['cassie'], 'catherine' => ['cathy', 'caty', 'kate', 'kitty'], 'cecilia' => ['cecily', 'sissy'], 'charles' => ['charlie', 'chuck'], 'chester' => ['chet'], 'crystal' => ['chris'], 'lucinda' => ['cindy', 'lucy'], 'clarissa' => ['cissy'], 'nicholas' => ['claus', 'klaus', 'nick'], 'cleatus' => ['cleat'], 'clementine' => ['clem'], 'clifton' => ['cliff'], 'chloe' => ['clo'], 'cornelia' => ['connie', 'conny', 'neely'], 'corinne' => ['cora', 'ora'], 'courtney' => ['corky'], 'cornelius' => ['cory'], 'lucretia' => ['creasey'], 'christine' => ['crissy'], 'cyrus' => ['cy'], 'cynthia' => ['cyndi'], 'margaret' => ['daisy', 'madge', 'maggie', 'maggy', 'may', 'meg', 'midge', 'peg', 'peggy'], 'daniel' => ['dan', 'danny'], 'david' => ['dave', 'davy'], 'deborah' => ['deb', 'debby'], 'deanne' => ['dee'], 'diedre' => ['deedee'], 'fidelia' => ['delia'], 'delilah' => ['della', 'lila'], 'frederick' => ['derick', 'fred', 'freddie', 'fritz'], 'diane' => ['di', 'didi'], 'eurydice' => ['dicey'], 'richard' => ['dick', 'rich', 'rick'], 'delores' => ['dodie', 'lola'], 'martha' => ['dolly', 'marty'], 'isadora' => ['dora', 'issy'], 'dorothy' => ['dotty'], 'douglas' => ['doug'], 'edward' => ['ed', 'neil'], 'edith' => ['edie'], 'euphemia' => ['effie'], 'eleanor' => ['elaine', 'ellen', 'elly', 'helen', 'lana', 'lenora'], 'elisha' => ['eli'], 'luella' => ['ella', 'ellie'], 'heloise' => ['eloise'], 'emeline' => ['emily', 'millie'], 'emily' => ['emma', 'erma'], 'ephraim' => ['eph'], 'earnestine' => ['erna', 'ernie'], 'loretta' => ['etta'], 'evelyn' => ['ev', 'eve', 'evie'], 'frances' => ['fan', 'fran', 'frankie', 'sis'], 'veronica' => ['fanny', 'ronnie'], 'faith' => ['fay'], 'josephine' => ['fina', 'josie'], 'florence' => ['flo', 'flora', 'flossie'], 'franklin' => ['frank'], 'gabriel' => ['gab', 'gabe'], 'gabrielle' => ['gabby'], 'eugene' => ['gene'], 'gwenevere' => ['genny'], 'geoffrey' => ['geoff'], 'gerald' => ['gerry'], 'gustaf' => ['gus'], 'hamilton' => ['ham'], 'henry' => ['hank', 'harry'], 'johanna' => ['hanna'], 'johannes' => ['hans'], 'esther' => ['hester', 'stella'], 'ignatius' => ['iggy'], 'john' => ['jack', 'johnny'], 'jacqueline' => ['jackie'], 'jacob' => ['jake'], 'jennifer' => ['jan', 'jenny'], 'virginia' => ['jane', 'virgie'], 'jedediah' => ['jed'], 'jeffrey' => ['jeff'], 'winifred' => ['jennifer', 'winnie'], 'jeremiah' => ['jeremy', 'jerry'], 'julia' => ['jill'], 'james' => ['jim', 'jimmy'], 'joseph' => ['joe', 'joey'], 'jonathan' => ['jon'], 'joshua' => ['josh'], 'joyce' => ['joy'], 'judith' => ['judy'], 'kathlene' => ['kathy'], 'katherine' => ['katie'], 'calista' => ['kissy'], 'christopher' => ['kit'], 'leonard' => ['len', 'leo', 'leon'], 'magdalena' => ['lena'], 'felipe' => ['leno'], 'letitia' => ['lettie', 'tish'], 'lewis' => ['lew'], 'elisa' => ['lisa'], 'lorraine' => ['lorrie'], 'charlotte' => ['lottie'], 'louis' => ['lou', 'louie'], 'mehitable' => ['mabel'], 'madeline' => ['maddie', 'maddy'], 'mary' => ['mame', 'mamie', 'moll', 'molly'], 'amanda' => ['manda'], 'samantha' => ['mandy', 'manthy'], 'emanuel' => ['manny'], 'marcia' => ['marcy'], 'marjorie' => ['marge', 'margie'], 'marvin' => ['marv'], 'mathew' => ['mat'], 'matthias' => ['matt'], 'matilda' => ['maud', 'maude', 'tilda'], 'maurice' => ['maury'], 'maxwell' => ['max'], 'melvin' => ['mel'], 'philomena' => ['mena'], 'mervin' => ['merv'], 'michael' => ['mick', 'mickey', 'mike', 'mischa'], 'millicent' => ['milly'], 'milton' => ['milt'], 'wilhelmina' => ['mimi', 'mina', 'willie'], 'minerva' => ['mini', 'minnie'], 'mitchell' => ['mitch'], 'ramona' => ['mona'], 'morton' => ['mort', 'morty'], 'muriel' => ['mur'], 'almira' => ['myra'], 'abel' => ['nab'], 'ignacio' => ['nacho'], 'nadine' => ['nadia'], 'nancy' => ['nan', 'nana'], 'nathaniel' => ['nate'], 'norton' => ['ned'], 'helen' => ['nell', 'nellie', 'nelly'], 'agnes' => ['nessie', 'senga'], 'jeanette' => ['nettie'], 'henrietta' => ['netty'], 'eunice' => ['nicie', 'nicy'], 'nicole' => ['nikki'], 'ann' => ['nina'], 'juanita' => ['nita'], 'elnora' => ['nora'], 'norman' => ['norm'], 'obediah' => ['obed'], 'oliver' => ['ollie'], 'paul' => ['pablo'], 'francisco' => ['pacho', 'paco', 'pancho'], 'patrick' => ['paddy', 'pat'], 'pamela' => ['pam'], 'patricia' => ['patsy', 'patty'], 'penelope' => ['penny'], 'josefa' => ['pepa'], 'jose' => ['pepe'], 'percival' => ['percy'], 'peter' => ['pete'], 'orphelia' => ['phelia'], 'philip' => ['phil'], 'paula' => ['polly'], 'priscilla' => ['prissy', 'silla'], 'prudence' => ['prudy'], 'aquilla' => ['quil', 'quillie'], 'raphael' => ['rafe'], 'randolph' => ['randy'], 'erasmus' => ['rasmus'], 'raymond' => ['ray'], 'reginald' => ['reg', 'reggie'], 'irene' => ['rena'], 'norita' => ['rita'], 'rodrigo' => ['rod'], 'rhoda' => ['rodie'], 'ronald' => ['ron', 'ronny'], 'rosetta' => ['rosie'], 'roxanne' => ['roxy'], 'leroy' => ['roy'], 'rudolph' => ['rudy'], 'russell' => ['russ'], 'sarah' => ['sadie', 'sal', 'sally'], 'samuel' => ['sam'], 'sandra' => ['sandy'], 'asenath' => ['sene', 'senie'], 'sherman' => ['sherm'], 'silas' => ['si'], 'isabella' => ['sibella', 'tibbie'], 'sidney' => ['sid'], 'silvia' => ['silvie'], 'solomon' => ['sol'], 'eustacia' => ['stacia', 'stacy'], 'stanly' => ['stan'], 'steven' => ['steve'], 'stephen' => ['steven'], 'stewart' => ['stew'], 'suzanne' => ['sue', 'susie', 'suzy'], 'suzanna' => ['sukey'], 'thadeus' => ['tad'], 'theodore' => ['ted', 'teddy', 'theo'], 'aristotle' => ['telly'], 'theresa' => ['terry', 'tess', 'tracy'], 'antonia' => ['tia'], 'otilia' => ['tilly'], 'timothy' => ['tim', 'timmy'], 'martina' => ['tina'], 'tobias' => ['toby'], 'thomas' => ['tom'], 'anthony' => ['tony'], 'katherina' => ['trina'], 'gertrude' => ['trudi', 'trudy'], 'ursula' => ['ursie', 'ursy'], 'evangeline' => ['vangie'], 'vernon' => ['vern'], 'violet' => ['vi'], 'victor' => ['vic'], 'victoria' => ['vicky'], 'vincent' => ['vin', 'vinny'], 'lavina' => ['vina'], 'virgil' => ['virg'], 'vivian' => ['viv'], 'yvonne' => ['vonnie'], 'walter' => ['wally', 'walt'], 'webster' => ['web'], 'gwendolen' => ['wendy'], 'wesley' => ['wes'], 'edwin' => ['winn'], 'woodrow' => ['woody'], 'christina' => ['xina'], 'isaac' => ['zac', 'zak'], 'zachariah' => ['zach'], 'zebulon' => ['zeb'], 'zedekiah' => ['zed'], 'ezekiel' => ['zeke'], 'albertina' => ['zena'], 'zephaniah' => ['zeph']}

  # Map between attribute as symbol to string text for presentation
  # Person::DISPLAY_ATTRIBUTES[:name_last] -> 'Last Name:*'
  DISPLAY_ATTRIBUTES = {
    name_first: 'First Name:*',
    name_last: 'Last Name:*',
    name_middle: 'Middle Name:',
    name_prefix: 'Prefix:',
    name_suffix: 'Suffix:',
    name_nick: 'Nickname:',
    birthplace: 'Birthplace:'
  }.freeze
end
