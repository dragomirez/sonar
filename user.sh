#!/bin/bash

SONARQUBE_URL="https://sonarqube.rbblan.internal"
SONARQUBE_ADMIN_TOKEN="your-admin-token"
PROJECT_TAG="your-project-tag"  # Replace with the desired tag

# Prompt for the user to add
read -p "Enter the username to add: " USER_LOGIN

# Get user UID
USER_UID=$(curl -s -X GET -H "Authorization: Bearer $SONARQUBE_ADMIN_TOKEN" "$SONARQUBE_URL/api/users/search" -d "logins=$USER_LOGIN" | jq -r '.users[0].uuid')

if [ -n "$USER_UID" ]; then
    # Get projects with the specified tag
    PROJECT_KEYS=$(curl -s -X GET -H "Authorization: Bearer $SONARQUBE_ADMIN_TOKEN" "$SONARQUBE_URL/api/projects/search" -d "tags=$PROJECT_TAG" | jq -r '.components[].key')

    if [ -n "$PROJECT_KEYS" ]; then
        for PROJECT_KEY in $PROJECT_KEYS; do
            # Add user all permissions to each project
            curl -X POST -H "Authorization: Bearer $SONARQUBE_ADMIN_TOKEN" -H "Content-Type: application/json" -d "{\"login\": \"$USER_UID\", \"projectKey\": \"$PROJECT_KEY\", \"permission\": \"admin\"}" "$SONARQUBE_URL/api/permissions/add_user"
        done

        echo "User permissions added successfully."
        
        # Display projects to which the user has been added
        echo "Projects added for user $USER_LOGIN:"
        echo "$PROJECT_KEYS"
    else
        echo "No projects found with the specified tag."
    fi
else
    echo "User not found."
fi
