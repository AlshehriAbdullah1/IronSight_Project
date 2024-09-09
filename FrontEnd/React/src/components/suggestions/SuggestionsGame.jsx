import React from 'react'
import { useState } from 'react'
import SuggestionsGameList from './SuggestionsGameList'
import '../../css/components/suggestionsGame.css'

const SuggestionsGame = () => {
  const [numOfSuggest, setNumOfSuggest] = useState(0)
  return (
    <div className='content'>
      <div className='title'>
      Game Suggestions
      </div>
      <div className="report-container">
        <h2 className="report-title">Current Suggestions</h2>
        <p className="report-number">{numOfSuggest}</p>
      </div>
      <div className="suggestions-table-label">
        <h2>Current Game Suggestions</h2>
        </div>
      <SuggestionsGameList setNumOfSuggest={setNumOfSuggest} />
    </div>
  )
}

export default SuggestionsGame