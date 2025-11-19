# ------------------------------------------------------------------------------
# 5. UTILITY FUNCTIONS SCRIPT
# ------------------------------------------------------------------------------

# File: claude-code-utils.ps1

function Write-ColorOutput {
    param(
        [string]$Message, 
        [ValidateSet("Black","Blue","Cyan","DarkBlue","DarkCyan","DarkGray","DarkGreen","DarkMagenta","DarkRed","DarkYellow","Gray","Green","Magenta","Red","White","Yellow")]
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function New-PromptFiles {
    param([switch]$WithDesignSystem)
    
    # Create all the prompt template files
    # (Implementation would include all the prompt creation logic)
    
    Write-ColorOutput "Prompt files created" "Green"
}

function New-TemplateFiles {
    param([string]$ProjectType)
    
    # Create template files based on project type
    # (Implementation would include template creation logic)
    
    Write-ColorOutput "Template files created for $ProjectType" "Green"
}

function New-DesignSystemFiles {
    # Create design system related files and directories
    # (Implementation would include design system setup)
    
    Write-ColorOutput "Design system files created" "Green"
}

# Export functions for use in other scripts
# Export-ModuleMember -Function Write-ColorOutput, New-PromptFiles, New-TemplateFiles, New-DesignSystemFiles