"use client"
import { Avatar, Button, ButtonProps, Menu, MenuItem, MenuProps, SxProps, Theme } from '@mui/material';
import React, { PropsWithChildren } from 'react'

interface ButtonDropDownProps extends React.HTMLAttributes<HTMLDivElement> {
    children: React.ReactNode;
    title:string;
    buttonProps?: ButtonProps;
    sx?: SxProps<Theme>;
}

const ButtonDropDown: React.FC<ButtonDropDownProps> = ({children, title, buttonProps, sx}) => {
    const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);
    const open = Boolean(anchorEl);
    const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
      setAnchorEl(event.currentTarget);
    };
    const handleClose = () => {
      setAnchorEl(null);
    };

    return (
        <div>
          <Avatar>
            <Button
              id="basic-button"
              aria-controls={open ? 'basic-menu' : undefined}
              aria-haspopup="true"
              aria-expanded={open ? 'true' : undefined}
              onClick={handleClick}
              {...buttonProps}
              sx={sx}
              
            >
              {title}
            </Button>
          </Avatar>
          <Menu
            id="basic-menu"
            anchorEl={anchorEl}
            open={open}
            onClose={handleClose}
            MenuListProps={{
              'aria-labelledby': 'basic-button',
            }}
          >
            
            <MenuItem onClick={handleClose}>
            {children}
            </MenuItem>
          </Menu>
        </div>
      );
}

export default ButtonDropDown