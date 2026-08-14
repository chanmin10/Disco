import 'pretendard/dist/web/static/pretendard.css'
import '../shared/tokens.css'
import './popup.css'

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>
)
