import torch
import torch.nn as nn

class ConvLSTMCell(nn.Module):
    '''
    Class for Convolutional LSTM Cell.
    '''
    def __init__(self, input_dim, hidden_dim, kernel_size, bias):
        """
        Initialize ConvLSTM cell.

        Args:
            input_dim (int): Number of channels of input tensor.
            hidden_dim (int): Number of channels of hidden state.
            kernel_size (int): Size of the convolutional kernel.
            bias (bool): Whether or not to add the bias.
        """
        super(ConvLSTMCell, self).__init__()

        self.input_dim = input_dim
        self.hidden_dim = hidden_dim
        self.kernel_size = kernel_size
        self.bias = bias
        self.padding = int((kernel_size - 1) / 2)

        self.conv = nn.Conv2d(in_channels=self.input_dim + self.hidden_dim,
                              out_channels=4 * self.hidden_dim,
                              kernel_size=self.kernel_size,
                              padding=self.padding,
                              bias=self.bias)
        
    def forward(self, input, cur_state):
        """
        Forward pass of ConvLSTM cell.

        Args:
            input (tensor): Input tensor.
            cur_state (tuple): Current state containing hidden state and cell state.

        Returns:
            tensor: Next hidden state.
            tensor: Next cell state.
        """
        h_cur, c_cur = cur_state

        combined = torch.cat([input, h_cur], dim=1)

        combined_conv = self.conv(combined)
        cc_i, cc_f, cc_o, cc_g = torch.split(combined_conv, self.hidden_dim, dim=1)
        i = torch.sigmoid(cc_i)
        f = torch.sigmoid(cc_f)
        o = torch.sigmoid(cc_o)
        g = torch.tanh(cc_g)

        c_next = f * c_cur + i * g
        h_next = o * torch.tanh(c_next)

        return h_next, c_next
    
    def init_hidden(self, batch_size, height, width):
        """
        Initialize hidden states.

        Args:
            batch_size (int): Batch size.
            height (int): Height of input tensor.
            width (int): Width of input tensor.

        Returns:
            tensor: Initial hidden state.
            tensor: Initial cell state.
        """
        return (torch.zeros(batch_size, self.hidden_dim, height, width, device=self.conv.weight.device),
                torch.zeros(batch_size, self.hidden_dim, height, width, device=self.conv.weight.device))
    

class ConvLSTM(nn.Module):
    '''
    Class for Convolutional LSTM layer.
    '''
    def __init__(self, input_dim, hidden_dim, kernel_size, bias=True):
        '''
        Initialize ConvLSTM layer.

        Args:
            input_dim (int): Number of input dimensions (channels).
            hidden_dim (int): Number of hidden dimensions (channels).
            kernel_size (int): Convolution kernel size.
            bias (bool): Add bias or not.
        '''
        super(ConvLSTM, self).__init__()

        self.cell = ConvLSTMCell(input_dim=input_dim, hidden_dim=hidden_dim, kernel_size=kernel_size, bias=bias)

    def forward(self, input, hidden_state=None):
        """
        Forward pass of ConvLSTM layer.

        Args:
            input (tensor): Input tensor.
            hidden_state (tuple, optional): Initial hidden state. Defaults to None.

        Returns:
            tensor: Output tensor.
        """
        b, seq_len, channel, h, w = input.size()

        hidden_state = self._init_hidden(batch_size=b, height=h, width=w)
        h, c = hidden_state
        output_inner = []

        for t in range(seq_len):
            h, c = self.cell(input=input[:, t, :, :, :], cur_state=[h, c])
            output_inner.append(h)

        output_inner = torch.stack(output_inner, dim=1)
        return output_inner
    
    def _init_hidden(self, batch_size, height, width):
        """
        Initialize hidden states.

        Args:
            batch_size (int): Batch size.
            height (int): Height of input tensor.
            width (int): Width of input tensor.

        Returns:
            tensor: Initial hidden state.
        """
        return self.cell.init_hidden(batch_size=batch_size, height=height, width=width)


class ConvLSTMModel(nn.Module):
    '''
    Class for Crime Hotspot Prediction model.
    '''
    def __init__(self, input_dim, hidden_dim, kernel_size, bias=True):
        '''
        Initialize ConvLSTM Model.

        Args:
            input_dim (int): Number of input dimensions (channels).
            hidden_dim (int): Number of hidden dimensions (channels).
            kernel_size (int): Convolution kernel size.
            bias (bool): Add bias or not.
        '''
        super(ConvLSTMModel, self).__init__()

        self.convlstm1 = ConvLSTM(input_dim=input_dim, hidden_dim=hidden_dim, kernel_size=kernel_size, bias=bias)
        self.batch_norm1 = nn.BatchNorm3d(num_features=hidden_dim)

        self.convlstm2 = ConvLSTM(input_dim=hidden_dim, hidden_dim=hidden_dim, kernel_size=kernel_size, bias=bias)
        self.batch_norm2 = nn.BatchNorm3d(num_features=hidden_dim)

        self.convlstm3 = ConvLSTM(input_dim=hidden_dim, hidden_dim=hidden_dim, kernel_size=kernel_size, bias=bias)
        self.batch_norm3 = nn.BatchNorm3d(num_features=hidden_dim)

        self.convlstm4 = ConvLSTM(input_dim=hidden_dim, hidden_dim=hidden_dim, kernel_size=kernel_size, bias=bias)
        self.batch_norm4 = nn.BatchNorm3d(num_features=hidden_dim)

        self.maxpool = nn.MaxPool3d(kernel_size=1, stride=[2, 1, 1])
        self.dropout = nn.Dropout(p=0.5)
        self.sigmoid = nn.Sigmoid()

        self.conv3d = nn.Conv3d(in_channels=hidden_dim, out_channels=int(hidden_dim / 4), kernel_size=(1, 3, 3), padding=(0, 1, 1), bias=True)

        self.fc_input = int(int(hidden_dim / 4) * 10 * 10)
        self.fc = nn.Linear(in_features=self.fc_input, out_features=2)  # Output will be latitude and longitude
    
    def forward(self, input):
        """
        Forward pass of ConvLSTM model.

        Args:
            input (tensor): Input tensor.

        Returns:
            tensor: Output tensor.
        """
        out = self.convlstm1(input)
        out = out.permute(0, 2, 1, 3, 4)
        out = self.batch_norm1(out)
        out = self.maxpool(out)
        out = self.dropout(out)

        out = out.permute(0, 2, 1, 3, 4)
        out = self.convlstm2(out)
        out = out.permute(0, 2, 1, 3, 4)
        out = self.batch_norm2(out)
        out = self.maxpool(out)
        out = self.dropout(out)

        out = out.permute(0, 2, 1, 3, 4)
        out = self.convlstm3(out)
        out = out.permute(0, 2, 1, 3, 4)
        out = self.batch_norm3(out)
        out = self.maxpool(out)
        out = self.dropout(out)

        out = out.permute(0, 2, 1, 3, 4)
        out = self.convlstm4(out)
        out = out.permute(0, 2, 1, 3, 4)
        out = self.batch_norm4(out)
        out = self.maxpool(out)
        out = self.dropout(out)

        out = self.conv3d(out)
        out = out.view(-1, 1, 1, self.fc_input)
        out = self.fc(out)
        out = self.sigmoid(out)
        return out
