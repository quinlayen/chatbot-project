#!/bin/bash

BACKEND_LOG="backend/fastapi.log"
FRONTEND_LOG="frontend/streamlit.log"
CHROMA_LOG="chromadb/chromadb.log"

touch $BACKEND_LOG $FRONTEND_LOG $CHROMA_LOG
chmod 666 $BACKEND_LOG $FRONTEND_LOG $CHROMA_LOG

check_process() {
    local name=$1
    local log_file=$2
    local pattern=$3
    
    sleep 3 
    if pgrep -f "$pattern" > /dev/null; then
        echo "$name is running successfully."
    else
        echo "Error: $name failed to start. Check $log_file for details."
    fi
}


echo "Starting ChromaDB..."
cd chromadb
chroma run --path . >> "../$CHROMA_LOG" 2>&1 &
cd ..
check_process "ChromaDB" "$CHROMA_LOG" "chroma run"


echo "Starting Backend..."
cd backend
uvicorn backend:app --reload >> "../$BACKEND_LOG" 2>&1 &
cd ..
check_process "Backend" "$BACKEND_LOG" "uvicorn backend:app"


echo "Starting Frontend..."
cd frontend
streamlit run chatbot.py >> "../$FRONTEND_LOG" 2>&1 &
cd ..
check_process "Frontend" "$FRONTEND_LOG" "streamlit run chatbot.py"

wait