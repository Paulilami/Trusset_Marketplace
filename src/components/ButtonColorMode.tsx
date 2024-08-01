// components/ButtonColorMode.tsx
"use client";
import React from 'react';
import { Button, IconButton, useTheme } from '@mui/material';
import { useThemeContext } from '@/app/ThemeContext';
import Brightness4Icon from '@mui/icons-material/Brightness4';
import Brightness7Icon from '@mui/icons-material/Brightness7';

export const ButtonColorMode = () => {
  const { toggleTheme, currentTheme } = useThemeContext();
  const theme = useTheme();

  return (
    <IconButton onClick={toggleTheme}  sx={{color: theme.palette.text.primary}}>
      {currentTheme.palette.mode === 'dark' ? <Brightness7Icon /> : <Brightness4Icon />}

    </IconButton >
  );
};
