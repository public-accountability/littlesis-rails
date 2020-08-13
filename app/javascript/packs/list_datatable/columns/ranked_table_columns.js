import { BasicColumn } from './basic_column.js';

function RankColumn(){
  return  {
    data: 'rank',
    name: 'rank',
    width: '5%',
    className: 'rank'
  }
}

export function RankedTableColumns(config){
  if ( config['ranked_table'] ){
    return [
      new BasicColumn('default_sort_position'),
      new RankColumn()
    ]
  } else {
    return []
  }
}
